import smartpy as sp

# Define the contract class
class DelegableContract(sp.Contract):
    def __init__(self, owner, delegate):
        self.init(owner = owner, delegate = delegate)
    
    # Define the "delegate" function, which allows the owner to change the delegate
    @sp.entry_point
    def delegate(self, delegate):
        # Check if the caller is the owner of the contract
        sp.verify(sp.sender == self.data.owner)
        
        # Update the delegate
        self.data.delegate = delegate
        
    # Define the "call" function, which is used to interact with the contract
    @sp.entry_point
    def call(self, params):
        # Check if the caller is the delegate
        sp.verify(sp.sender == self.data.delegate)
        
        # Update the contract based on the parameters provided
        self.data.update(params)

# Create an instance of the contract, with the specified owner and delegate addresses
contract = DelegableContract
