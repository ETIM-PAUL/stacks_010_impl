import { describe, expect, it, beforeEach } from "vitest";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;
const wallet3 = accounts.get("wallet_3")!;

const CONTRACT_NAME = "SIP_O10";

describe("SIP-010 VEN Token Tests", () => {
  
  beforeEach(() => {
    // Reset simnet state before each test
    simnet.setEpoch("3.0");
  });

  // =============================================================================
  // Basic SIP-010 Read-Only Tests
  // =============================================================================

  describe("Token Metadata", () => {
    it("should return correct token name", () => {
      const { result } = simnet.callReadOnlyFn(
        CONTRACT_NAME,
        "get-name",
        [],
        deployer
      );
      expect(result).toBeOk(Cl.stringAscii("VEN Token"));
    });

    it("should return correct token symbol", () => {
      const { result } = simnet.callReadOnlyFn(
        CONTRACT_NAME,
        "get-symbol",
        [],
        deployer
      );
      expect(result).toBeOk(Cl.stringAscii("VT"));
    });

    it("should return correct decimals", () => {
      const { result } = simnet.callReadOnlyFn(
        CONTRACT_NAME,
        "get-decimals",
        [],
        deployer
      );
      expect(result).toBeOk(Cl.uint(6));
    });

    it("should return token URI as none", () => {
      const { result } = simnet.callReadOnlyFn(
        CONTRACT_NAME,
        "get-token-uri",
        [],
        deployer
      );
      expect(result).toBeOk(Cl.none());
    });

    it("should return contract info", () => {
      const { result } = simnet.callReadOnlyFn(
        CONTRACT_NAME,
        "get-contract-info",
        [],
        deployer
      );
      expect(result).toBeOk(
        Cl.tuple({
          name: Cl.stringAscii("VEN Token"),
          symbol: Cl.stringAscii("VT"),
          decimals: Cl.uint(6),
          "max-supply": Cl.uint(1000000000000),
          "current-supply": Cl.uint(0),
          "contract-owner": Cl.principal(deployer)
        })
      );
    });
  });

  // Additional test suites omitted for brevity
  // Run the tests with: npm test
});
