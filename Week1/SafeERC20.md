# SafeERC20

## Why does it exist?

SafeERC20 is a library provided by OpenZeppelin that exists to safely handle interactions with ERC20 tokens. It was introduced to address some of the limitations of interacting with ERC20 tokens directly: 

1. **Handling Non-Standard ERC20 Tokens**: Although ERC20 is a widely adopted standard on Ethereum, not all tokens follow the ERC20 standard strictly. Some tokens deviate from the standard by not returning a boolean value (true or false) after `transfer`, `transferFrom`, or `approve` functions. This can lead to bugs when interacting with these non-compliant tokens or even cause lost tokens or allow failed transactions that go unnoticed.

2. **Ensuring Safe Token Transfers**: SafeERC20 helps ensure that token transfers, approvals, and other operations succeed by wrapping the standard ERC20 functions (`transfer`, `transferFrom`, `approve`, etc.) and checking the return value. If the token doesn't return true, or if it fails in another way, SafeERC20 will handle the failure gracefully, ensuring the contract doesn’t continue under the assumption that the transaction succeeded.

3. **Prevent Allowance Front-Running**: One of the common vulnerabilities in ERC20 tokens is the front-running risk when using the approve function to set allowances. This only applies when a user attempts to increase/decrease an allowance from an existing non-zero allowance and only calls approve once. SafeERC20 mitigates this

## When should it be used?

1. **Interacting with External Tokens**: Any time your smart contract interacts with external ERC20 tokens (i.e., tokens you don’t control), it’s recommended to use SafeERC20. You cannot guarantee that external tokens follow the ERC20 standard perfectly, so SafeERC20 adds a layer of security and reliability to these interactions.