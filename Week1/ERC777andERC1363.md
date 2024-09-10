# ERC777 and ERC1363

## ERC777

### Key Problems Solved:

1. **Lack of Granular Control in ERC20**: ERC20 tokens have simple transfer functions (transfer and transferFrom), but they don’t allow fine-grained control over how tokens are received. This lack of control can lead to issues like tokens being sent to contracts that are not prepared to handle them.

2. **No Pre- or Post-Transaction Hooks**: ERC777 introduces hooks that allow for more complex logic before and after token transfers. For example, a contract or account can define behavior when tokens are sent or received.

3. **Operator System**: ERC777 introduces a new operator system, allowing users to authorize third parties to send tokens on their behalf. This is more flexible than the approve/transferFrom mechanism in ERC20, as operators can be authorized to handle multiple transactions without pre-approving specific amounts.

4. **Atomic Transactions**: In ERC20, users need to first approve a contract to spend their tokens before the contract can call transferFrom. This two-step process adds additional overhead and can lead to user errors. ERC777’s operator system eliminates the need for the approve/transferFrom pattern by allowing operators to be approved for more dynamic interactions.

### Key Issues:

1. **Reentrancy Vulnerability**: The hooks ERC777 adds additional complexity and can introduce issues such as reentrancy attacks if the token standard is not implemented correctly (e.g., a token transfer triggering code that could cause re-entrance into the contract).

2. **Gas Efficiency**: ERC777 transactions may require more gas due to the additional logic associated with hooks and operators, making it more expensive to use compared to ERC20.

## ERC1363

### Key Problems Solved:

1. **Simplify Approvals for Payments**: ERC1363 addresses the two-step process required by ERC20 tokens, where a user must first call approve and then transferFrom to allow a contract to spend their tokens. ERC1363 allows a contract to handle payments and approvals in a single call. This improves the user experience and reduces the number of transactions needed.

2. **Enable Payable Token Transfers**: ERC1363 introduces a mechanism for making tokens "payable," meaning that contracts can automatically react to token transfers, similar to how a contract reacts to Ether payments. This allows contracts to perform specific actions when receiving tokens.