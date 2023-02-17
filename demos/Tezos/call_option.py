import smartpy as sp

class ModifiableContract(sp.Contract):
    def __init__(self, owner):
        self.init(owner=owner, value=0)

    @sp.entry_point
    def call(self, params):
        sp.verify(sp.sender == self.data.owner)
        self.data.update(params)

    @sp.entry_point
    def call_option(self, params):
        sp.verify(sp.amount == self.data.value)
        sp.transfer(self.data.owner, sp.amount)
        self.data.update(params)

    def update(self, params):
        self.data.value += 1
        self.data.new_storage = params.new_storage
        self.data.new_code = params.new_code

# Create an instance of the contract, with the specified owner address
contract = ModifiableContract(sp.address("tz1..."))
