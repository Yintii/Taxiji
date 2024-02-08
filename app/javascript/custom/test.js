document.addEventListener('turbo:load', async function() {
    console.log('turbo:load event fired');
    // A Web3Provider wraps a standard Web3 provider, which is
    // what MetaMask injects as window.ethereum into each page
    const provider = new ethers.providers.Web3Provider(window.ethereum)

    console.log(provider);
    // MetaMask requires requesting permission to connect users accounts
    let accounts = await provider.send("eth_requestAccounts", []);

    console.log(accounts);
    // The MetaMask plugin also allows signing transactions to
    // send ether and pay to change state within the blockchain.
    // For this, you need the account signer...
    const signer = provider.getSigner()
});