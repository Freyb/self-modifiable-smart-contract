import smartpy as sp

class UpdateSmartContract(sp.Contract):
    def __init__(self):
        self.init()

    @sp.entry_point
    def update(self, params):
        sp.verify(params.type == "update", message="Unsupported action")
        self.set_data(new_storage=params.new_storage, new_code=params.new_code)

@sp.add_test(name="UpdateSmartContract")
def test():
    c = UpdateSmartContract()

    # Test updating the storage and code
    c.update(type="update", new_storage="new storage", new_code="new code")
    sp.verify(c.data.new_storage == "new storage")
    sp.verify(c.data.new_code == "new code")

    # Test unsupported action
    with sp.revert("Unsupported action"):
        c.update(type="unsupported", new_storage="new storage", new_code="new code")
