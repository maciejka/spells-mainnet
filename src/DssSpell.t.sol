// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.6.12;

import "./DssSpell.t.base.sol";
import "dss-interfaces/Interfaces.sol";

contract DssSpellTest is DssSpellTestBase {

    uint256 constant APR_01_2021 = 1617235200;
    uint256 constant SEP_01_2021 = 1630454400;
    uint256 constant FEB_01_2022 = 1643673600;
    uint256 constant DEC_31_2022 = 1672444800;
    uint256 constant JAN_31_2023 = 1675123200;
    uint256 constant JUL_31_2023 = 1690761600;

    address constant SF_001_VEST_01    = 0xBC7fd5AA2016C3e2C8F0dBf4e919485C6BBb59e2;
    address constant SF_001_VEST_02    = 0xCC81578d163A04ea8d2EaE6904d0C8E61A84E1Bb;


    function testSpellIsCast_GENERAL() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0, "TestError/spell-description-length");
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description), "TestError/spell-description");

        if(address(spell) != address(spellValues.deployed_spell)) {
            assertEq(spell.expiration(), block.timestamp + spellValues.expiration_threshold, "TestError/spell-expiration");
        } else {
            assertEq(spell.expiration(), spellValues.deployed_spell_created + spellValues.expiration_threshold, "TestError/spell-expiration");

            // If the spell is deployed compare the on-chain bytecode size with the generated bytecode size.
            // extcodehash doesn't match, potentially because it's address-specific, avenue for further research.
            address depl_spell = spellValues.deployed_spell;
            address code_spell = address(new DssSpell());
            assertEq(getExtcodesize(depl_spell), getExtcodesize(code_spell), "TestError/spell-codesize");
        }

        assertTrue(spell.officeHours() == spellValues.office_hours_enabled, "TestError/spell-office-hours");

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done(), "TestError/spell-not-done");

        checkSystemValues(afterSpell);

        checkCollateralValues(afterSpell);
    }

    function testPayouts() public {
        address sne = wallets.addr("SNE_WALLET");
        address tech = wallets.addr("TECH_WALLET");
        address oraGas = wallets.addr("ORA_GAS");
        address oraGasEmerg = wallets.addr("ORA_GAS_EMERGENCY");

        uint256 snebal = dai.balanceOf(sne);
        uint256 techbal = dai.balanceOf(tech);
        uint256 oraGasbal = dai.balanceOf(oraGas);
        uint256 oraGasEmergbal = dai.balanceOf(oraGasEmerg);

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(dai.balanceOf(sne) - snebal, 229_792 * WAD);
        assertEq(dai.balanceOf(tech) - techbal, 1_069_250 * WAD);
        assertEq(dai.balanceOf(oraGas) - oraGasbal, 6_966_070 * WAD);
        assertEq(dai.balanceOf(oraGasEmerg) - oraGasEmergbal, 1_805_407 * WAD);

    }

    function testVestDAI() public {
        VestAbstract vest = VestAbstract(addr.addr("MCD_VEST_DAI"));

        uint streams = vest.ids();

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(vest.cap(), 1 * MILLION * WAD / 30 days);
        assertEq(vest.ids(), streams + 6);

        // // -----
        assertEq(vest.usr(22), wallets.addr("DUX_WALLET"));
        assertEq(vest.bgn(22), FEB_01_2022);
        assertEq(vest.clf(22), FEB_01_2022);
        assertEq(vest.fin(22), FEB_01_2022 + 364 days); // (28+31+30+31+30+31+31+30+31+30+31+31)
        assertEq(vest.mgr(22), address(0));
        assertEq(vest.res(22), 1);
        assertEq(vest.tot(22), 1_934_300 * WAD);
        assertEq(vest.rxd(22), 0);
        // // -----
        assertEq(vest.usr(23), wallets.addr("SES_WALLET"));
        assertEq(vest.bgn(23), FEB_01_2022);
        assertEq(vest.clf(23), FEB_01_2022);
        assertEq(vest.fin(23), FEB_01_2022 + 364 days); // (28+31+30+31+30+31+31+30+31+30+31+31)
        assertEq(vest.mgr(23), address(0));
        assertEq(vest.res(23), 1);
        assertEq(vest.tot(23), 5_844_444 * WAD);
        assertEq(vest.rxd(23), 0);
        // // -----
        assertEq(vest.usr(24), wallets.addr("SNE_WALLET"));
        assertEq(vest.bgn(24), FEB_01_2022);
        assertEq(vest.clf(24), FEB_01_2022);
        assertEq(vest.fin(24), FEB_01_2022 + 545 days); // (28+31+30+31+30+31+31+30+31+30+31+31+28+31+30+31+30+31)
        assertEq(vest.mgr(24), address(0));
        assertEq(vest.res(24), 1);
        assertEq(vest.tot(24), 257_500 * WAD);
        assertEq(vest.rxd(24), 0);
        // // -----
        assertEq(vest.usr(25), wallets.addr("TECH_WALLET"));
        assertEq(vest.bgn(25), FEB_01_2022);
        assertEq(vest.clf(25), FEB_01_2022);
        assertEq(vest.fin(25), FEB_01_2022 + 364 days); // (28+31+30+31+30+31+31+30+31+30+31+31)
        assertEq(vest.mgr(25), address(0));
        assertEq(vest.res(25), 1);
        assertEq(vest.tot(25), 2_486_400 * WAD);
        assertEq(vest.rxd(25), 0);
        // // -----
        assertEq(vest.usr(26), wallets.addr("SF_WALLET"));
        assertEq(vest.bgn(26), FEB_01_2022);
        assertEq(vest.clf(26), FEB_01_2022);
        assertEq(vest.fin(26), FEB_01_2022 + 545 days); // (28+31+30+31+30+31+31+30+31+30+31+31+28+31+30+31+30+31)
        assertEq(vest.mgr(26), address(0));
        assertEq(vest.res(26), 1);
        assertEq(vest.tot(26), 494_502 * WAD);
        assertEq(vest.rxd(26), 0);
        // // -----
        assertEq(vest.usr(27), wallets.addr("RWF_WALLET"));
        assertEq(vest.bgn(27), FEB_01_2022);
        assertEq(vest.clf(27), FEB_01_2022);
        assertEq(vest.fin(27), FEB_01_2022 + 333 days); // (28+31+30+31+30+31+31+30+31+30+31)
        assertEq(vest.mgr(27), address(0));
        assertEq(vest.res(27), 1);
        assertEq(vest.tot(27), 1_705_000 * WAD);
        assertEq(vest.rxd(27), 0);
        // // -----

        // // Give admin powers to Test contract address and make the vesting unrestricted for testing
        hevm.store(
            address(vest),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(1))
        );
        vest.unrestrict(22);
        vest.unrestrict(23);
        vest.unrestrict(24);
        vest.unrestrict(25);
        vest.unrestrict(26);
        vest.unrestrict(27);
        // //

        hevm.warp(DEC_31_2022);
        uint256 prevBalanceDUX  = dai.balanceOf(wallets.addr("DUX_WALLET"));
        uint256 prevBalanceSES  = dai.balanceOf(wallets.addr("SES_WALLET"));
        uint256 prevBalanceSNE  = dai.balanceOf(wallets.addr("SNE_WALLET"));
        uint256 prevBalanceTECH = dai.balanceOf(wallets.addr("TECH_WALLET"));
        uint256 prevBalanceSF   = dai.balanceOf(wallets.addr("SF_WALLET"));
        uint256 prevBalanceRWF  = dai.balanceOf(wallets.addr("RWF_WALLET"));

        uint256 vestedDUX = vest.accrued(22);
        assertEq(vestedDUX, 1769565659340659340659340);
        uint256 vestedSES = vest.accrued(23);
        assertEq(vestedSES, 5346702890109890109890109);
        uint256 vestedSNE = vest.accrued(24);
        assertEq(vestedSNE, 157334862385321100917431);
        uint256 vestedTECH = vest.accrued(25);
        assertEq(vestedTECH, 2274646153846153846153846);
        uint256 vestedSF = vest.accrued(26);
        assertEq(vestedSF, 302145258715596330275229);
        uint256 vestedRWF = vest.accrued(27);
        assertEq(vestedRWF, 1705000000000000000000000);

        vest.vest(22);
        vest.vest(23);
        vest.vest(24);
        vest.vest(25);
        vest.vest(26);
        vest.vest(27);

        assertEq(dai.balanceOf(wallets.addr("DUX_WALLET")), prevBalanceDUX + vestedDUX);
        assertEq(dai.balanceOf(wallets.addr("SES_WALLET")), prevBalanceSES + vestedSES);
        assertEq(dai.balanceOf(wallets.addr("SNE_WALLET")), prevBalanceSNE + vestedSNE);
        assertEq(dai.balanceOf(wallets.addr("TECH_WALLET")), prevBalanceTECH + vestedTECH);
        assertEq(dai.balanceOf(wallets.addr("SF_WALLET")), prevBalanceSF + vestedSF);
        assertEq(dai.balanceOf(wallets.addr("RWF_WALLET")), prevBalanceRWF + vestedRWF);
    }

    function testYankedDaiStreams() public {
        VestAbstract vest = VestAbstract(addr.addr("MCD_VEST_DAI"));

        assertEq(vest.fin(20), 1651276800, "MKT Vest Pre fin");
        assertEq(vest.fin(15), 1672444800, "RWF Vest Pre fin");

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(vest.fin(20), block.timestamp, "MKT Vest Post fin should be now");
        assertEq(vest.fin(15), block.timestamp, "RWF Vest Post fin should be now");
    }

    function testVestMKR() public {
        VestAbstract vest = VestAbstract(addr.addr("MCD_VEST_MKR_TREASURY"));
        uint streams = vest.ids();
        assertEq(streams, 17, "17 existing streams");

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(vest.cap(), 1100 * WAD / 365 days);
        assertEq(vest.ids(), streams + 2);

        assertEq(vest.usr(18), SF_001_VEST_01);
        assertEq(vest.bgn(18), SEP_01_2021);
        assertEq(vest.clf(18), SEP_01_2021 + 365 days);
        assertEq(vest.fin(18), SEP_01_2021 + 3 * 365 days);
        assertEq(vest.mgr(18), wallets.addr("SF_WALLET"));
        assertEq(vest.res(18), 1);
        assertEq(vest.tot(18), 240 * WAD);
        assertEq(vest.rxd(18), 0);

        assertEq(vest.usr(19), SF_001_VEST_02);
        assertEq(vest.bgn(19), APR_01_2021);
        assertEq(vest.clf(19), APR_01_2021 + 365 days);
        assertEq(vest.fin(19), APR_01_2021 + 3 * 365 days);
        assertEq(vest.mgr(19), wallets.addr("SF_WALLET"));
        assertEq(vest.res(19), 1);
        assertEq(vest.tot(19), 240 * WAD);
        assertEq(vest.rxd(19), 0);

        // Give admin powers to Test contract address and make the vesting unrestricted for testing
        hevm.store(
            address(vest),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(1))
        );
        vest.unrestrict(18);
        vest.unrestrict(19);
        //

        uint256 prevRecipientBalance01 = gov.balanceOf(SF_001_VEST_01);
        uint256 prevRecipientBalance02 = gov.balanceOf(SF_001_VEST_02);
        uint256 prevPauseBalance = gov.balanceOf(pauseProxy);
        hevm.warp(SEP_01_2021 + 365 days);
        uint256 vested01 = vest.accrued(18);
        assertEq(vested01, 80000000000000000000, "vested01 eq 80000000000000000000");
        uint256 vested02 = vest.accrued(19);
        assertEq(vested02, 113534246575342465753, "vested02 eq 113534246575342465753"); // vesting starts earlier
        vest.vest(18);
        vest.vest(19);

        assertEq(gov.balanceOf(SF_001_VEST_01), prevRecipientBalance01 + vested01, "token balance sfvest01");
        assertEq(gov.balanceOf(SF_001_VEST_02), prevRecipientBalance02 + vested02, "token balance sfvest02");
        assertEq(gov.balanceOf(pauseProxy), prevPauseBalance - (vested01 + vested02), "pauseProxy should have equivalent less MKR");
    }

    function testCollateralIntegrations() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
    }

    function testLerps() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());
    }

    function testNewChainlogValues() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new chainlog values tests here
        assertEq(chainLog.getAddress("CLIP_FAB"), addr.addr("CLIP_FAB"));

        assertEq(chainLog.version(), "1.9.12");
    }

    function testNewIlkRegistryValues() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
    }

    function testFailWrongDay() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailDay();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooEarly() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailEarly();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooLate() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailLate();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testOnTime() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
    }

    function testCastCost() public {
        vote(address(spell));
        spell.schedule();

        castPreviousSpell();
        hevm.warp(spell.nextCastTime());
        uint256 startGas = gasleft();
        spell.cast();
        uint256 endGas = gasleft();
        uint256 totalGas = startGas - endGas;

        assertTrue(spell.done());
        // Fail if cast is too expensive
        assertTrue(totalGas <= 10 * MILLION);
    }

    // The specific date doesn't matter that much since function is checking for difference between warps
    function test_nextCastTime() public {
        hevm.warp(1606161600); // Nov 23, 20 UTC (could be cast Nov 26)

        vote(address(spell));
        spell.schedule();

        uint256 monday_1400_UTC = 1606744800; // Nov 30, 2020
        uint256 monday_2100_UTC = 1606770000; // Nov 30, 2020

        // Day tests
        hevm.warp(monday_1400_UTC);                                    // Monday,   14:00 UTC
        assertEq(spell.nextCastTime(), monday_1400_UTC);               // Monday,   14:00 UTC

        if (spell.officeHours()) {
            hevm.warp(monday_1400_UTC - 1 days);                       // Sunday,   14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_1400_UTC - 2 days);                       // Saturday, 14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_1400_UTC - 3 days);                       // Friday,   14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC - 3 days);  // Able to cast

            hevm.warp(monday_2100_UTC);                                // Monday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC + 1 days);  // Tuesday,  14:00 UTC

            hevm.warp(monday_2100_UTC - 1 days);                       // Sunday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_2100_UTC - 2 days);                       // Saturday, 21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_2100_UTC - 3 days);                       // Friday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            // Time tests
            uint256 castTime;

            for(uint256 i = 0; i < 5; i++) {
                castTime = monday_1400_UTC + i * 1 days; // Next day at 14:00 UTC
                hevm.warp(castTime - 1 seconds); // 13:59:59 UTC
                assertEq(spell.nextCastTime(), castTime);

                hevm.warp(castTime + 7 hours + 1 seconds); // 21:00:01 UTC
                if (i < 4) {
                    assertEq(spell.nextCastTime(), monday_1400_UTC + (i + 1) * 1 days); // Next day at 14:00 UTC
                } else {
                    assertEq(spell.nextCastTime(), monday_1400_UTC + 7 days); // Next monday at 14:00 UTC (friday case)
                }
            }
        }
    }

    function testFail_notScheduled() public view {
        spell.nextCastTime();
    }

    function test_use_eta() public {
        hevm.warp(1606161600); // Nov 23, 20 UTC (could be cast Nov 26)

        vote(address(spell));
        spell.schedule();

        uint256 castTime = spell.nextCastTime();
        assertEq(castTime, spell.eta());
    }

    function test_OSMs() private { // make public to use
        vote(address(spell));
        spell.schedule();
        hevm.warp(spell.nextCastTime());
        spell.cast();
        assertTrue(spell.done());

        // Track OSM authorizations here
    }

    function test_Medianizers() private { // make public to use
        vote(address(spell));
        spell.schedule();
        hevm.warp(spell.nextCastTime());
        spell.cast();
        assertTrue(spell.done());

        // Track Median authorizations here
    }

    function test_auth() public {
        checkAuth(false);
    }

    function test_auth_in_sources() public {
        checkAuth(true);
    }

    // Verifies that the bytecode of the action of the spell used for testing
    // matches what we'd expect.
    //
    // Not a complete replacement for Etherscan verification, unfortunately.
    // This is because the DssSpell bytecode is non-deterministic because it
    // deploys the action in its constructor and incorporates the action
    // address as an immutable variable--but the action address depends on the
    // address of the DssSpell which depends on the address+nonce of the
    // deploying address. If we had a way to simulate a contract creation by
    // an arbitrary address+nonce, we could verify the bytecode of the DssSpell
    // instead.
    //
    // Vacuous until the deployed_spell value is non-zero.
    function test_bytecode_matches() public {
        address expectedAction = (new DssSpell()).action();
        address actualAction   = spell.action();
        uint256 expectedBytecodeSize;
        uint256 actualBytecodeSize;
        assembly {
            expectedBytecodeSize := extcodesize(expectedAction)
            actualBytecodeSize   := extcodesize(actualAction)
        }

        uint256 metadataLength = getBytecodeMetadataLength(expectedAction);
        assertTrue(metadataLength <= expectedBytecodeSize);
        expectedBytecodeSize -= metadataLength;

        metadataLength = getBytecodeMetadataLength(actualAction);
        assertTrue(metadataLength <= actualBytecodeSize);
        actualBytecodeSize -= metadataLength;

        assertEq(actualBytecodeSize, expectedBytecodeSize);
        uint256 size = actualBytecodeSize;
        uint256 expectedHash;
        uint256 actualHash;
        assembly {
            let ptr := mload(0x40)

            extcodecopy(expectedAction, ptr, 0, size)
            expectedHash := keccak256(ptr, size)

            extcodecopy(actualAction, ptr, 0, size)
            actualHash := keccak256(ptr, size)
        }
        assertEq(expectedHash, actualHash);
    }
}
