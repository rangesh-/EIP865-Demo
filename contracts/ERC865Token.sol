pragma solidity ^0.4.0;
import "zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";

contract ERC865Token is BasicToken
{
    string public constant name = "ERC865 Token";
    string public constant symbol = "865";
    uint8 public constant decimals = 0;
    uint256 public totalSupply = 2500;
    mapping(bytes => bool) signatures;
    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
    event ApprovalPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
    
    constructor() public{
        balances[msg.sender] = totalSupply;
    }
    
    function transferPreSigned(
        bytes _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(signatures[_signature] == false);
         bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
         address from = recover(hashedTx, _signature);
        require(from != address(0));
         balances[from] = balances[from].sub(_value).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        Transfer(from, _to, _value);
        Transfer(from, msg.sender, _fee);
        TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }
    
     function transferPreSignedHashing(
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(bytes4(0x48664c16), _token, _to, _value, _fee, _nonce);
    }
    
    function recover(bytes32 hash, bytes sig) public pure returns (address) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      //Check the signature length
      if (sig.length != 65) {
        return (address(0));
      }
       // Divide the signature in r, s and v variables
      assembly {
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
      }
       // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
      if (v < 27) {
        v += 27;
      }
       // If the version is correct return the signer address
      if (v != 27 && v != 28) {
        return (address(0));
      } else {
        return ecrecover(hash, v, r, s);
      }
    }
}
