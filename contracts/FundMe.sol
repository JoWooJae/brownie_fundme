// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import SafeMAth
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// helpful site
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

contract FundMe {
    using SafeMathChainlink for uint256; // we want to use 'safemath' at 'cahinlink'

    mapping(address => uint256) public addressToAmountFunded;
    // I am curious how much 'money' 'address sent'

    address[] public funders; // people who put money, address management which put money

    // when we withdraw our money, we want only owner can withdraw.---------------------
    address public owner;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    //  when we withdraw our money, we want only owner can withdraw.---------------------

    function fund() public payable {
        // 50$
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        // What the ETH -> USD conversion rate

        funders.push(msg.sender); // put address who fund money to 'funders'. in the funders there is address who fund money
    }

    // take function from other contract

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    // https://docs.chain.link/docs/ethereum-addresses/
    // at that chain link, i take eth-use of rinkby

    // take function from other contract
    function getPrice() public view returns (uint256) {
        // (
        //     uint80 roundId,
        //     int256 answer,
        //     uint256 startedAt,
        //     uint256 updatedAt,
        //     uint80 answeredInRound
        // ) = priceFeed.latestRoundData();
        // return uint256(answer);

        // up and down is same code
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000 to f usd
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
        // 1gwei =  0.000002588089729980 dollar ,
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        // only this contract's owner/admin can withdraw money
        // require(msg.sender == owner) ;               // we will satisfy up sentence with 'modifier'
        msg.sender.transfer(address(this).balance);

        // We witndraw money, so we should update withdrawed address to 0.
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];

            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
        // we should 'reset funder array'
    }
}

// https://eth-converter.com/
// https://docs.chain.link/docs/ethereum-addresses/
// https://www.npmjs.com/package/@chainlink/contracts
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol
