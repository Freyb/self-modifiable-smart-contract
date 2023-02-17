import smartpy as sp

class DelegableContract(sp.Contract):
    def __init__(self, owner, delegate):
        self.init(owner=owner, delegate=delegate)

    @sp.entry_point
    def delegate(self, delegate):
        sp.verify(sp.sender == self.data.owner)
        self.data.delegate = delegate

    @sp.entry_point
    def call(self, params):
        sp.verify(sp.sender == self.data.delegate)
        self.data.update(params)

    def update(self, params):
        self.data.new_storage = params.new_storage
        self.data.new_code = params.new_code

# Create an instance of the contract, with the specified owner and delegate addresses
contract = DelegableContract(sp.address("tz1..."), sp.address("tz2..."))
