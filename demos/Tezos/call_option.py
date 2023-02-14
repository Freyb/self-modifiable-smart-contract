import smartpy as sp

# Define the contract class
class ModifiableContract(sp.Contract):
    def __init__(self, owner):
        self.init(owner = owner)
    
    # Define the "call" function, which can be used to modify the contract
    @sp.entry_point
    def call(self, params):
        # Check if the caller is the owner of the contract
        sp.verify(sp.sender == self.data.owner)
        
        # Update the contract based on the parameters provided
        self.data.update(params)
        
# Create an instance of the contract, with the specified owner address
contract = ModifiableContract
