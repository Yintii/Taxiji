document.addEventListener('turbo:load', async function() {
    console.log('turbo:load event fired');
    const ABI = [{ "inputs": [{ "internalType": "address payable", "name": "depositAddress_", "type": "address" }], "stateMutability": "nonpayable", "type": "constructor" }, { "inputs": [], "name": "depositAddress", "outputs": [{ "internalType": "address payable", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "getDepositAddress", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "address payable", "name": "_withholding_wallet", "type": "address" }, { "internalType": "uint256", "name": "withholding_amount", "type": "uint256" }, { "internalType": "uint256", "name": "processing_fee", "type": "uint256" }], "name": "sendFunds", "outputs": [], "stateMutability": "payable", "type": "function" }, { "inputs": [{ "internalType": "address payable", "name": "depositAddress_", "type": "address" }], "name": "setDepositAddress", "outputs": [], "stateMutability": "nonpayable", "type": "function" }];
    const provider = new ethers.BrowserProvider(window.ethereum)
    let accounts = await provider.send("eth_requestAccounts", []);
    let signer = await provider.getSigner()
    const taxiji = new ethers.Contract('0x7509Aa80Ef5a70f0e8EC15018916574097DD1137', ABI, signer);

    const withholdSingleTransaction = async (transaction) => {
        const { user_withholding_wallet, user_transacting_wallet, amt_to_withhold, fee, hash, user } = transaction;

        console.log("Amount to withhold: ", amt_to_withhold)
        console.log("Its type: ", typeof amt_to_withhold)

        console.log("Fee amount: ", fee)
        console.log("Fee type: ", typeof fee)

        console.log("Processing this transaction for ", user_transacting_wallet);

        const tx = await taxiji.sendFunds(
            user_withholding_wallet, 
            amt_to_withhold, 
            fee, 
            { value: amt_to_withhold + fee }
        );

        console.log("Mining transaction...")

        await tx.wait();

        console.log("Transaction mined: ", tx.hash);
      

        response = fetch(baseURL, {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({
            hash,
            user,
            user_transacting_wallet
          })
        });
        


//        window.location.reload();

    };

    document.querySelectorAll('#pending-transactions button').forEach((button) => {
        button.addEventListener('click', async (event) => {
            const percentage = event.target.dataset.percentage;
            console.log('percentage: ', percentage)
            const user_withholding_wallet = event.target.dataset.withholding_wallet;
            console.log('user_withholding_wallet: ', user_withholding_wallet);
            const user_transacting_wallet = event.target.dataset.transacting_wallet;
            console.log('user transacting wallet: ', user_transacting_wallet);
            const amt_to_withhold = BigInt(event.target.dataset.amt | 0);
            console.log('amt_to_withhold: ', amt_to_withhold)
            const fee = BigInt(event.target.dataset.amt | 0 * (percentage / 100));
            console.log('fee: ', fee)
            const hash = event.target.dataset.hash;
            console.log('hash: ', hash)
            const user = event.target.dataset.user;
            console.log('user: ', user)


            const _transaction = {
                user_withholding_wallet,
                user_transacting_wallet,
                amt_to_withhold,
                fee,
                hash,
                user
            };
            withholdSingleTransaction(_transaction);
        });
    });
});
