############################################################################
############################################################################
##
## Copyright 2018 Alpha Data Parallel Systems Ltd.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
############################################################################
############################################################################


#
# This file contains PACKAGE_PIN constraints for signals of SDRAM bank 0 when in
# a x72 configuration.
#
# NOTE: Does NOT include twin-die signals: CKE1, CS#1, ODT1. If targeting a twin-die
#       configuration, also include ddr4sdram_locs_b0_twin_die.xdc in your project.
#

set_property PACKAGE_PIN G16 [get_ports "c0_sys_clk_p"]
set_property PACKAGE_PIN G15 [get_ports "c0_sys_clk_n"]

set_property IOSTANDARD DIFF_HSTL_I_12 [get_ports "c0_sys_clk_p"]
set_property IOSTANDARD DIFF_HSTL_I_12 [get_ports "c0_sys_clk_n"]


set_property PACKAGE_PIN C17 [get_ports "c0_ddr4_dqs_t[0]"]
set_property PACKAGE_PIN B17 [get_ports "c0_ddr4_dqs_c[0]"]
set_property PACKAGE_PIN C22 [get_ports "c0_ddr4_dqs_t[1]"]
set_property PACKAGE_PIN B22 [get_ports "c0_ddr4_dqs_c[1]"]
set_property PACKAGE_PIN K16 [get_ports "c0_ddr4_dqs_t[2]"]
set_property PACKAGE_PIN J16 [get_ports "c0_ddr4_dqs_c[2]"]
set_property PACKAGE_PIN N21 [get_ports "c0_ddr4_dqs_t[3]"]
set_property PACKAGE_PIN N22 [get_ports "c0_ddr4_dqs_c[3]"]
set_property PACKAGE_PIN F17 [get_ports "c0_ddr4_dqs_t[4]"]
set_property PACKAGE_PIN E17 [get_ports "c0_ddr4_dqs_c[4]"]
set_property PACKAGE_PIN G24 [get_ports "c0_ddr4_dqs_t[5]"]
set_property PACKAGE_PIN F24 [get_ports "c0_ddr4_dqs_c[5]"]
set_property PACKAGE_PIN M20 [get_ports "c0_ddr4_dqs_t[6]"]
set_property PACKAGE_PIN M21 [get_ports "c0_ddr4_dqs_c[6]"]
set_property PACKAGE_PIN T18 [get_ports "c0_ddr4_dqs_t[7]"]
set_property PACKAGE_PIN T17 [get_ports "c0_ddr4_dqs_c[7]"]
set_property PACKAGE_PIN N12 [get_ports "c0_ddr4_dqs_t[8]"]
set_property PACKAGE_PIN M12 [get_ports "c0_ddr4_dqs_c[8]"]

set_property PACKAGE_PIN B20 [get_ports "c0_ddr4_dq[0]"]
set_property PACKAGE_PIN C18 [get_ports "c0_ddr4_dq[1]"]
set_property PACKAGE_PIN B19 [get_ports "c0_ddr4_dq[2]"]
set_property PACKAGE_PIN A18 [get_ports "c0_ddr4_dq[3]"]
set_property PACKAGE_PIN A20 [get_ports "c0_ddr4_dq[4]"]
set_property PACKAGE_PIN D18 [get_ports "c0_ddr4_dq[5]"]
set_property PACKAGE_PIN A19 [get_ports "c0_ddr4_dq[6]"]
set_property PACKAGE_PIN A17 [get_ports "c0_ddr4_dq[7]"]
set_property PACKAGE_PIN C21 [get_ports "c0_ddr4_dq[8]"]
set_property PACKAGE_PIN D23 [get_ports "c0_ddr4_dq[9]"]
set_property PACKAGE_PIN A24 [get_ports "c0_ddr4_dq[10]"]
set_property PACKAGE_PIN B24 [get_ports "c0_ddr4_dq[11]"]
set_property PACKAGE_PIN B21 [get_ports "c0_ddr4_dq[12]"]
set_property PACKAGE_PIN C23 [get_ports "c0_ddr4_dq[13]"]
set_property PACKAGE_PIN D21 [get_ports "c0_ddr4_dq[14]"]
set_property PACKAGE_PIN A22 [get_ports "c0_ddr4_dq[15]"]
set_property PACKAGE_PIN J19 [get_ports "c0_ddr4_dq[16]"]
set_property PACKAGE_PIN M17 [get_ports "c0_ddr4_dq[17]"]
set_property PACKAGE_PIN K18 [get_ports "c0_ddr4_dq[18]"]
set_property PACKAGE_PIN L19 [get_ports "c0_ddr4_dq[19]"]
set_property PACKAGE_PIN J18 [get_ports "c0_ddr4_dq[20]"]
set_property PACKAGE_PIN M16 [get_ports "c0_ddr4_dq[21]"]
set_property PACKAGE_PIN J20 [get_ports "c0_ddr4_dq[22]"]
set_property PACKAGE_PIN L18 [get_ports "c0_ddr4_dq[23]"]
set_property PACKAGE_PIN T22 [get_ports "c0_ddr4_dq[24]"]
set_property PACKAGE_PIN R20 [get_ports "c0_ddr4_dq[25]"]
set_property PACKAGE_PIN P23 [get_ports "c0_ddr4_dq[26]"]
set_property PACKAGE_PIN N23 [get_ports "c0_ddr4_dq[27]"]
set_property PACKAGE_PIN R22 [get_ports "c0_ddr4_dq[28]"]
set_property PACKAGE_PIN P21 [get_ports "c0_ddr4_dq[29]"]
set_property PACKAGE_PIN R21 [get_ports "c0_ddr4_dq[30]"]
set_property PACKAGE_PIN P20 [get_ports "c0_ddr4_dq[31]"]
set_property PACKAGE_PIN E20 [get_ports "c0_ddr4_dq[32]"]
set_property PACKAGE_PIN F18 [get_ports "c0_ddr4_dq[33]"]
set_property PACKAGE_PIN F20 [get_ports "c0_ddr4_dq[34]"]
set_property PACKAGE_PIN E18 [get_ports "c0_ddr4_dq[35]"]
set_property PACKAGE_PIN F19 [get_ports "c0_ddr4_dq[36]"]
set_property PACKAGE_PIN G20 [get_ports "c0_ddr4_dq[37]"]
set_property PACKAGE_PIN H18 [get_ports "c0_ddr4_dq[38]"]
set_property PACKAGE_PIN H17 [get_ports "c0_ddr4_dq[39]"]
set_property PACKAGE_PIN G22 [get_ports "c0_ddr4_dq[40]"]
set_property PACKAGE_PIN E23 [get_ports "c0_ddr4_dq[41]"]
set_property PACKAGE_PIN G21 [get_ports "c0_ddr4_dq[42]"]
set_property PACKAGE_PIN F23 [get_ports "c0_ddr4_dq[43]"]
set_property PACKAGE_PIN H24 [get_ports "c0_ddr4_dq[44]"]
set_property PACKAGE_PIN E22 [get_ports "c0_ddr4_dq[45]"]
set_property PACKAGE_PIN H23 [get_ports "c0_ddr4_dq[46]"]
set_property PACKAGE_PIN E21 [get_ports "c0_ddr4_dq[47]"]
set_property PACKAGE_PIN J23 [get_ports "c0_ddr4_dq[48]"]
set_property PACKAGE_PIN K22 [get_ports "c0_ddr4_dq[49]"]
set_property PACKAGE_PIN K23 [get_ports "c0_ddr4_dq[50]"]
set_property PACKAGE_PIN L24 [get_ports "c0_ddr4_dq[51]"]
set_property PACKAGE_PIN J24 [get_ports "c0_ddr4_dq[52]"]
set_property PACKAGE_PIN L20 [get_ports "c0_ddr4_dq[53]"]
set_property PACKAGE_PIN L23 [get_ports "c0_ddr4_dq[54]"]
set_property PACKAGE_PIN K20 [get_ports "c0_ddr4_dq[55]"]
set_property PACKAGE_PIN P16 [get_ports "c0_ddr4_dq[56]"]
set_property PACKAGE_PIN R18 [get_ports "c0_ddr4_dq[57]"]
set_property PACKAGE_PIN R17 [get_ports "c0_ddr4_dq[58]"]
set_property PACKAGE_PIN N19 [get_ports "c0_ddr4_dq[59]"]
set_property PACKAGE_PIN R16 [get_ports "c0_ddr4_dq[60]"]
set_property PACKAGE_PIN N18 [get_ports "c0_ddr4_dq[61]"]
set_property PACKAGE_PIN N16 [get_ports "c0_ddr4_dq[62]"]
set_property PACKAGE_PIN N17 [get_ports "c0_ddr4_dq[63]"]
set_property PACKAGE_PIN N14 [get_ports "c0_ddr4_dq[64]"]
set_property PACKAGE_PIN R12 [get_ports "c0_ddr4_dq[65]"]
set_property PACKAGE_PIN P15 [get_ports "c0_ddr4_dq[66]"]
set_property PACKAGE_PIN P14 [get_ports "c0_ddr4_dq[67]"]
set_property PACKAGE_PIN M14 [get_ports "c0_ddr4_dq[68]"]
set_property PACKAGE_PIN R13 [get_ports "c0_ddr4_dq[69]"]
set_property PACKAGE_PIN L15 [get_ports "c0_ddr4_dq[70]"]
set_property PACKAGE_PIN M15 [get_ports "c0_ddr4_dq[71]"]

set_property PACKAGE_PIN D14 [get_ports "c0_ddr4_adr[0]"]
set_property PACKAGE_PIN F15 [get_ports "c0_ddr4_adr[1]"]
set_property PACKAGE_PIN G12 [get_ports "c0_ddr4_adr[2]"]
set_property PACKAGE_PIN E13 [get_ports "c0_ddr4_adr[3]"]
set_property PACKAGE_PIN A13 [get_ports "c0_ddr4_adr[4]"]
set_property PACKAGE_PIN C12 [get_ports "c0_ddr4_adr[5]"]
set_property PACKAGE_PIN B12 [get_ports "c0_ddr4_adr[6]"]
set_property PACKAGE_PIN F12 [get_ports "c0_ddr4_adr[7]"]
set_property PACKAGE_PIN D13 [get_ports "c0_ddr4_adr[8]"]
set_property PACKAGE_PIN C13 [get_ports "c0_ddr4_adr[9]"]
set_property PACKAGE_PIN C14 [get_ports "c0_ddr4_adr[10]"]
set_property PACKAGE_PIN E12 [get_ports "c0_ddr4_adr[11]"]
set_property PACKAGE_PIN B14 [get_ports "c0_ddr4_adr[12]"]
set_property PACKAGE_PIN J15 [get_ports "c0_ddr4_adr[13]"]
set_property PACKAGE_PIN H12 [get_ports "c0_ddr4_adr[14]"]
set_property PACKAGE_PIN B16 [get_ports "c0_ddr4_adr[15]"]
set_property PACKAGE_PIN A15 [get_ports "c0_ddr4_adr[16]"]

set_property PACKAGE_PIN K13 [get_ports "c0_ddr4_ck_t[0]"]
set_property PACKAGE_PIN K12 [get_ports "c0_ddr4_ck_c[0]"]

set_property PACKAGE_PIN B15 [get_ports "c0_ddr4_ba[0]"]
set_property PACKAGE_PIN F14 [get_ports "c0_ddr4_ba[1]"]

set_property PACKAGE_PIN G14 [get_ports "c0_ddr4_bg[0]"]
set_property PACKAGE_PIN H14 [get_ports "c0_ddr4_bg[1]"]

set_property PACKAGE_PIN D15 [get_ports "c0_ddr4_cs_n[0]"]
set_property PACKAGE_PIN E16 [get_ports "c0_ddr4_cke[0]"]
set_property PACKAGE_PIN D16 [get_ports "c0_ddr4_odt[0]"]

set_property PACKAGE_PIN F13 [get_ports "c0_ddr4_act_n"]
set_property PACKAGE_PIN A14 [get_ports "c0_ddr4_reset_n"]

set_property PACKAGE_PIN D19 [get_ports "c0_ddr4_dm_dbi_n[0]"]
set_property PACKAGE_PIN D24 [get_ports "c0_ddr4_dm_dbi_n[1]"]
set_property PACKAGE_PIN L17 [get_ports "c0_ddr4_dm_dbi_n[2]"]
set_property PACKAGE_PIN T23 [get_ports "c0_ddr4_dm_dbi_n[3]"]
set_property PACKAGE_PIN H19 [get_ports "c0_ddr4_dm_dbi_n[4]"]
set_property PACKAGE_PIN H21 [get_ports "c0_ddr4_dm_dbi_n[5]"]
set_property PACKAGE_PIN K21 [get_ports "c0_ddr4_dm_dbi_n[6]"]
set_property PACKAGE_PIN P19 [get_ports "c0_ddr4_dm_dbi_n[7]"]
set_property PACKAGE_PIN P13 [get_ports "c0_ddr4_dm_dbi_n[8]"]