// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

//crowdsourcing
contract FundMe {

    using SafeMathChainlink for uint256;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    //payable means can be used to pay for things
    function fund() public payable {

        //minimum donation amount is 1/10 of penny or $0.001 set in gwei x 10^18
        //** means raised or ^
        uint256 minimumUSD = .001 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "Error, reverting and not accepting.");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        //what the ETH -> USD conversion rate


    }

    //need to be able to inject metamask in order to test
    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //(uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answerInRound) = priceFeed.latestRoundData();
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }

    //modifiers are used to change the behavior of functions in a declarative way
    modifier onlyOwner {
        require(msg.sender == owner, "Unable to complete transaction. Only the owner may do this.");
        _;
    }

    function withdraw() payable onlyOwner public {
        //only want the contract admin/owner to be able to do this
        //require msg.sender = owner
        msg.sender.transfer(address(this).balance);
        
        //reset funders when all is withdrawn
        for (uint256 funderIndex = 0; funderIndex<funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //clears all the funders by setting to new arrayd
        funders = new address[](0);
    }

}
