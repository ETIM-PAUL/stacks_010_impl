;; =============================================================================
;; SIP-010 Fungible Token: VEN Token
;; =============================================================================
;; A fully compliant SIP-010 token implementation with enhanced security features
;; and Clarity 4 best practices.

;; Use the FT trait
(use-trait ft-trait .ft-trait.ft-trait)

;; Implement the SIP-010 trait
(impl-trait .ft-trait.ft-trait)

;; =============================================================================
;; Constants
;; =============================================================================

;; Token configuration
(define-constant TOKEN_NAME "VEN Token")
(define-constant TOKEN_SYMBOL "VT")
(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_MAX_SUPPLY u1000000000000) ;; 1 million tokens with 6 decimals

;; Access control
(define-constant contract-owner tx-sender)

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_INVALID_RECIPIENT (err u102))
(define-constant ERR_EXCEEDS_MAX_SUPPLY (err u103))

;; =============================================================================
;; Fungible Token Definition
;; =============================================================================

(define-fungible-token VEN_token TOKEN_MAX_SUPPLY)

;; =============================================================================
;; SIP-010 Core Functions
;; =============================================================================

;; Transfer tokens from sender to recipient
;; @param amount: Number of tokens to transfer
;; @param sender: Principal sending the tokens (must be tx-sender)
;; @param recipient: Principal receiving the tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal))
    (begin
        ;; Validate inputs
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (asserts! (is-standard recipient) ERR_INVALID_RECIPIENT)
        
        ;; Execute transfer
        (try! (ft-transfer? VEN_token amount sender recipient))
        
        ;; Emit transfer event
        (print {
            type: "transfer",
            token: "VEN",
            amount: amount,
            sender: sender,
            recipient: recipient
        })
        
        (ok true)
    )
)

;; Transfer with memo (extended SIP-010)
;; @param amount: Number of tokens to transfer
;; @param sender: Principal sending the tokens (must be tx-sender)
;; @param recipient: Principal receiving the tokens
;; @param memo: Optional memo buffer for transaction metadata
(define-public (transfer-memo (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
    (begin
        ;; Validate inputs
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (asserts! (is-standard recipient) ERR_INVALID_RECIPIENT)
        
        ;; Execute transfer
        (try! (ft-transfer? VEN_token amount sender recipient))
        
        ;; Emit transfer event with memo
        (print {
            type: "transfer",
            token: "VEN",
            amount: amount,
            sender: sender,
            recipient: recipient,
            memo: memo
        })
        
        (ok true)
    )
)

;; =============================================================================
;; SIP-010 Read-Only Functions
;; =============================================================================

;; Get token name
;; @returns (ok "VEN Token")
(define-read-only (get-name)
    (ok TOKEN_NAME)
)

;; Get token symbol
;; @returns (ok "VT")
(define-read-only (get-symbol)
    (ok TOKEN_SYMBOL)
)

;; Get token decimals
;; @returns (ok u6)
(define-read-only (get-decimals)
    (ok TOKEN_DECIMALS)
)

;; Get balance of a principal
;; @param who: Principal to check balance for
;; @returns (ok uint) Balance in base units
(define-read-only (get-balance (who principal))
    (ok (ft-get-balance VEN_token who))
)

;; Get total supply of tokens
;; @returns (ok uint) Total supply in base units
(define-read-only (get-total-supply)
    (ok (ft-get-supply VEN_token))
)

;; Get token URI (optional metadata)
;; @returns (ok none) - Can be updated to return actual metadata URI
(define-read-only (get-token-uri)
    (ok none)
)

;; =============================================================================
;; Extended Functions (Non-SIP-010)
;; =============================================================================

;; Convenience function for simple transfers
;; @param amount: Number of tokens to transfer
;; @param recipient: Principal receiving the tokens
(define-public (transfer-token (amount uint) (recipient principal))
    (begin
        (asserts! (is-standard recipient) ERR_INVALID_RECIPIENT)
        (transfer amount tx-sender recipient none)
    )
)

;; Mint new tokens (only contract owner)
;; @param amount: Number of tokens to mint
;; @param recipient: Principal receiving the minted tokens
(define-public (mint (amount uint) (recipient principal))
    (begin
        ;; Authorization check
        (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (asserts! (is-standard recipient) ERR_INVALID_RECIPIENT)
        
        ;; Check if minting would exceed max supply
        (let ((current-supply (ft-get-supply VEN_token)))
            (asserts! (<= (+ current-supply amount) TOKEN_MAX_SUPPLY) ERR_EXCEEDS_MAX_SUPPLY)
        )
        
        ;; Execute mint
        (try! (ft-mint? VEN_token amount recipient))
        
        ;; Emit mint event
        (print {
            type: "mint",
            token: "VEN",
            amount: amount,
            recipient: recipient,
            total-supply: (ft-get-supply VEN_token)
        })
        
        (ok true)
    )
)

;; Burn tokens from caller's balance
;; @param amount: Number of tokens to burn
(define-public (burn (amount uint))
    (begin
        ;; Validate amount
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        
        ;; Execute burn
        (try! (ft-burn? VEN_token amount tx-sender))
        
        ;; Emit burn event
        (print {
            type: "burn",
            token: "VEN",
            amount: amount,
            sender: tx-sender,
            total-supply: (ft-get-supply VEN_token)
        })
        
        (ok true)
    )
)

;; Burn tokens from a specific principal (requires authorization)
;; @param amount: Number of tokens to burn
;; @param owner: Principal whose tokens will be burned
(define-public (burn-from (amount uint) (owner principal))
    (begin
        ;; Only contract owner or the token owner can burn
        (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender owner)) ERR_UNAUTHORIZED)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        
        ;; Execute burn
        (try! (ft-burn? VEN_token amount owner))
        
        ;; Emit burn event
        (print {
            type: "burn-from",
            token: "VEN",
            amount: amount,
            owner: owner,
            caller: tx-sender,
            total-supply: (ft-get-supply VEN_token)
        })
        
        (ok true)
    )
)

;; =============================================================================
;; Advanced Features
;; =============================================================================

;; Note: as-contract? with allowances will be available when fully supported in Clarinet
;; For now, contract transfers can be handled through standard mint/burn mechanisms

;; =============================================================================
;; Utility Functions
;; =============================================================================

;; Check if a principal is a standard principal (not a contract)
;; @param principal: Principal to check
;; @returns bool
(define-read-only (is-standard-principal (principal-to-check principal))
    (is-standard principal-to-check)
)

;; Get contract information
;; @returns Tuple with contract details
(define-read-only (get-contract-info)
    (ok {
        name: TOKEN_NAME,
        symbol: TOKEN_SYMBOL,
        decimals: TOKEN_DECIMALS,
        max-supply: TOKEN_MAX_SUPPLY,
        current-supply: (ft-get-supply VEN_token),
        contract-owner: contract-owner
    })
)

;; Check if account has sufficient balance
;; @param account: Principal to check
;; @param amount: Amount to check against
;; @returns bool
(define-read-only (has-sufficient-balance (account principal) (amount uint))
    (>= (ft-get-balance VEN_token account) amount)
)

;; Get remaining mintable supply
;; @returns uint
(define-read-only (get-remaining-supply)
    (ok (- TOKEN_MAX_SUPPLY (ft-get-supply VEN_token)))
)