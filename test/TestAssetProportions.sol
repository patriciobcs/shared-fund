import "./setup/TestSetup.sol";

contract TestAssetProportions is TestSetup {
    function testAddConstantProportions() public {
        address tokenA = BTC;
        uint256 tokenABalance = 100;
        uint256 tokenAProportion = 2_500;

        addAsset(tokenA, tokenAProportion);
        remainingProportion -= tokenAProportion;

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), remainingProportion);

        address solToken = SOL;
        uint256 solBalance = 100;
        uint256 solProportion = 5_000;

        addAsset(solToken, solProportion);
        remainingProportion -= solProportion;

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), remainingProportion);
        assertEq(portfolio.getAssetProportion(solToken), solProportion);
    }

    function testRejectConstantProportionHigherThanAvailable() public {
        address tokenA = BTC;
        uint256 tokenABalance = 100;
        uint256 tokenAProportion = 7_500;

        addAsset(tokenA, tokenAProportion);
        remainingProportion -= tokenAProportion;

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), remainingProportion);

        address solToken = SOL;
        uint256 solBalance = 100;
        uint256 solProportion = 5_000;

        vm.expectRevert("REMAINING_PROPORTION_TOO_LOW");
        addAsset(solToken, solProportion);
    }

    function testChangeAssetProportionHigher() public {
        address tokenA = BTC;
        uint256 tokenAProportion = 2_500;

        addAsset(tokenA, tokenAProportion);

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), 7_500);

        portfolio.changeAssetProportion(tokenA, 5_000); // from 25% to 50%

        assertEq(portfolio.getAssetProportion(tokenA), 5_000);
        assertEq(portfolio.getRemainingProportion(), 5_000);
    }

    function testChangeAssetProportionLower() public {
        address tokenA = BTC;
        uint256 tokenAProportion = 5_000;

        addAsset(tokenA, tokenAProportion);

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), 5_000);

        portfolio.changeAssetProportion(tokenA, 2500); // from 50% to 25%

        assertEq(portfolio.getAssetProportion(tokenA), 2500);
        assertEq(portfolio.getRemainingProportion(), 7_500);
    }

    function testIncorrectOwner() public {
        address token = USDC;
        uint256 assetBalance = 100;
        addAsset(token, 2500);

        vm.startPrank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        portfolio.changeAssetProportion(token, 5000);
        vm.stopPrank();
    }
}
