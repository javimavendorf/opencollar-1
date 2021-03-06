/*------------------------------------------------------------------------------

 Auth, Build 181

 Wendy's OpenCollar Distribution
 https://github.com/wendystarfall/opencollar

--------------------------------------------------------------------------------

 OpenCollar v1.000 - v3.600 (OpenCollar - submission set free):

 Copyright © 2008, 2009, 2010 Cleo Collins, Garvin Twine, Lulu Pink,
 Master Starship, Nandana Singh, et al.

 The project in its original form concluded on October 19, 2011. Everything past
 this date is a derivative of OpenCollar's original SVN trunk from Google Code.

--------------------------------------------------------------------------------

 OpenCollar v3.700 - v3.720 (nirea's ocupdater):

 Copyright © 2011 nirea, Satomi Ahn, Sei Lisa

 https://github.com/OpenCollarUpdates/ocupdater/commits/release

--------------------------------------------------------------------------------

 OpenCollar v3.750 - v3.809 (Satomi's OpenCollarUpdates):

 Copyright © 2012 Satomi Ahn

 https://github.com/OpenCollarUpdates/ocupdater/commits/3.8
 https://github.com/OpenCollarUpdates/ocupdater/commits/beta

--------------------------------------------------------------------------------

 OpenCollar v3.809 - v3.843 (Joy's OpenCollar Evolution):

 Copyright © 2013 Joy Stipe

 https://github.com/JoyStipe/ocupdater/commits/Project_Evolution

--------------------------------------------------------------------------------

 OpenCollar v3.844 - v3.998 (Wendy's OpenCollar API 3.9):

 Copyright © 2013 Medea Destiny, Wendy Starfall
 Copyright © 2014 littlemousy, Romka Swallowtail, Wendy Starfall

 https://github.com/OpenCollar/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 Virtual Disgrace Collar v1.0.0 - v2.1.1 (virtualdisgrace.com):

 Copyright © 2011, 2012, 2013 Wendy Starfall
 Copyright © 2014 littlemousy, Wendy Starfall

 https://github.com/WendyStarfall/opencollar/commits/master
 https://github.com/VirtualDisgrace/opencollar/commits/master

--------------------------------------------------------------------------------

 OpenCollar v4.0.0 - v6.7.5 - Peanut build 9 (virtualdisgrace.com):

 Copyright © 2015 Garvin Twine, Romka Swallowtail, Wendy Starfall
 Copyright © 2016, 2017 Garvin Twine, stawberri, Wendy Starfall
 Copyright © 2018 Garvin Twine, Wendy Starfall

 https://github.com/VirtualDisgrace/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, see www.gnu.org/licenses/gpl-2.0

------------------------------------------------------------------------------*/

integer g_iBuild = 181;

string g_sWearerID;
list g_lOwner;
list g_lTrust;
list g_lBlock;
list g_lTempOwner;
integer g_iMaxUsers = 45;

key g_kGroup = "";
integer g_iGroupEnabled = FALSE;

string g_sParentMenu = "Main";
string g_sSubMenu = "Access";
integer g_iRunawayDisable=0;

string g_sDrop = "f364b699-fb35-1640-d40b-ba59bdd5f7b7";

integer CMD_ZERO = 0;
integer CMD_OWNER = 500;
integer CMD_TRUSTED = 501;
integer CMD_GROUP = 502;
integer CMD_WEARER = 503;
integer CMD_EVERYONE = 504;
integer CMD_BLOCKED = 520;

integer NOTIFY = 1002;
integer NOTIFY_OWNERS = 1003;
integer LOADPIN = -1904;
integer REBOOT = -1000;
integer LINK_DIALOG = 3;
integer LINK_RLV = 4;
integer LINK_SAVE = 5;
integer LINK_UPDATE = -10;
integer LM_SETTING_SAVE = 2000;
integer LM_SETTING_RESPONSE = 2002;
integer LM_SETTING_DELETE = 2003;

integer RLV_CMD = 6000;

integer DIALOG = -9000;
integer DIALOG_RESPONSE = -9001;
integer DIALOG_TIMEOUT = -9002;
integer SENSORDIALOG = -9003;
integer BUILD_REQUEST = 17760501;
integer AUTH_REQUEST = 600;
integer AUTH_REPLY = 601;
string UPMENU = "BACK";

integer g_iOpenAccess;
integer g_iLimitRange=1;
integer g_iVanilla;
integer g_iHardVanilla;
string g_sFlavor = "Vanilla";

list g_lMenuIDs;
integer g_iMenuStride = 3;

integer g_iFirstRun;
integer g_iIsLED;

string g_sSettingToken = "auth_";

string NameURI(string sID){
    return "secondlife:///app/agent/"+sID+"/about";
}

Dialog(string sID, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string sName, integer iSensor) {
    key kMenuID = llGenerateKey();
    if (iSensor)
        llMessageLinked(LINK_DIALOG, SENSORDIALOG, sID +"|"+sPrompt+"|0|``"+(string)AGENT+"`10`"+(string)PI+"`"+llList2String(lChoices,0)+"|"+llDumpList2String(lUtilityButtons, "`")+"|" + (string)iAuth, kMenuID);
    else
        llMessageLinked(LINK_DIALOG, DIALOG, sID + "|" + sPrompt + "|" + (string)iPage + "|" + llDumpList2String(lChoices, "`") + "|" + llDumpList2String(lUtilityButtons, "`") + "|" + (string)iAuth, kMenuID);
    integer iIndex = llListFindList(g_lMenuIDs, [sID]);
    if (~iIndex)
        g_lMenuIDs = llListReplaceList(g_lMenuIDs, [sID, kMenuID, sName], iIndex, iIndex + g_iMenuStride - 1);
    else
        g_lMenuIDs += [sID, kMenuID, sName];
}

AuthMenu(key kAv, integer iAuth) {
    string sPrompt = "\n[http://www.opencollar.at/access.html Access & Authorization]";
    integer iPercentage = llRound(((float)llGetListLength(g_lOwner+g_lTrust+g_lBlock)/(float)g_iMaxUsers)*100.0);
    sPrompt += "\n\nYou are using "+(string)iPercentage+"% of your global access list storage.";
    list lButtons = ["+ Owner", "+ Trust", "+ Block", "− Owner", "− Trust", "− Block"];
    if (g_kGroup=="") lButtons += ["Group ☐"];
    else lButtons += ["Group ☑"];
    if (g_iOpenAccess) lButtons += ["Public ☑"];
    else lButtons += ["Public ☐"];
    if (g_iVanilla) lButtons += g_sFlavor+" ☑";
    else lButtons += g_sFlavor+" ☐";
    lButtons += ["Runaway","Access List"];
    Dialog(kAv, sPrompt, lButtons, [UPMENU], 0, iAuth, "Auth",FALSE);
}

RemPersonMenu(key kID, string sToken, integer iAuth) {
    list lPeople;
    if (sToken=="owner") lPeople=g_lOwner;
    else if (sToken=="tempowner") lPeople=g_lTempOwner;
    else if (sToken=="trust") lPeople=g_lTrust;
    else if (sToken=="block") lPeople=g_lBlock;
    else return;
    if (lPeople)
        Dialog(kID, "\nChoose the person to remove:\n", lPeople, ["Remove All",UPMENU], -1, iAuth, "remove"+sToken, FALSE);
    else {
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"The list is empty",kID);
        AuthMenu(kID, iAuth);
    }
}

RemovePerson(string sPersonID, string sToken, key kCmdr, integer iPromoted) {
    list lPeople;
    if (sToken=="owner") lPeople=g_lOwner;
    else if (sToken=="tempowner") lPeople=g_lTempOwner;
    else if (sToken=="trust") lPeople=g_lTrust;
    else if (sToken=="block") lPeople=g_lBlock;
    else return;
    if (~llListFindList(g_lTempOwner,[(string)kCmdr]) && ! ~llListFindList(g_lOwner,[(string)kCmdr]) && sToken != "tempowner") {
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kCmdr);
        return;
    }
    integer iFound;
    if (lPeople) {
        integer index = llListFindList(lPeople,[sPersonID]);
        if (~index) {
            lPeople = llDeleteSubList(lPeople,index,index);
            if (!iPromoted) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+NameURI(sPersonID)+" removed from " + sToken + " list.",kCmdr);
            iFound = TRUE;
        } else if (llToLower(sPersonID) == "remove all") {
            llMessageLinked(LINK_DIALOG,NOTIFY,"1"+sToken+" list cleared.",kCmdr);
            lPeople = [];
            iFound = TRUE;
        }
    }
    if (iFound){
        if (lPeople)
            llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + sToken + "=" + llDumpList2String(lPeople, ","), "");
        else
            llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sSettingToken + sToken, "");
        llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, g_sSettingToken + sToken + "=" + llDumpList2String(lPeople, ","), "");
        if (sToken == "owner") {
            g_lOwner = lPeople;
            if (g_lOwner) SayOwners();
        }
        else if (sToken == "tempowner") g_lTempOwner = lPeople;
        else if (sToken == "trust") g_lTrust = lPeople;
        else if (sToken == "block") g_lBlock = lPeople;
    } else
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\""+NameURI(sPersonID) + "\" is not in "+sToken+" list.",kCmdr);
}

AddUniquePerson(string sPersonID, string sToken, key kID) {
    list lPeople;
    if (~llListFindList(g_lTempOwner,[(string)kID]) && ! ~llListFindList(g_lOwner,[(string)kID]) && sToken != "tempowner")
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
    else {
        if (llGetListLength(g_lOwner+g_lTrust+g_lBlock) >= g_iMaxUsers) {
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nSorry, we have reached a limit!\n\nYou now have 60 people on your combined global access lists. This means in order to add anyone else to a list, you will have to remove someone from either the Owner, Trust, or Block list.\n",kID);
            return;
        } else if (sToken == "owner") lPeople = g_lOwner;
        else if (sToken=="trust") {
            lPeople = g_lTrust;
            if (~llListFindList(g_lOwner,[sPersonID])) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nOops!\n\n"+NameURI(sPersonID)+" is already Owner! You should really trust them.\n",kID);
                return;
            } else if (sPersonID == g_sWearerID) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nOops!\n\n"+NameURI(sPersonID)+" doesn't belong on this list as the wearer of the %DEVICETYPE%. Instead try: /%CHANNEL% %PREFIX% vanilla on\n",kID);
                return;
            }
        } else if (sToken == "tempowner") {
            lPeople = g_lTempOwner;
            if (lPeople) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nSorry!\n\nYou can only be captured by one person at a time.\n",kID);
                return;
            }
        } else if (sToken == "block") {
            lPeople = g_lBlock;
            if (~llListFindList(g_lTrust,[sPersonID])) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nOops!\n\nYou trust "+NameURI(sPersonID)+". If you really want to block "+NameURI(sPersonID)+" then you should remove them as trusted first.\n",kID);
                return;
            } else if (~llListFindList(g_lOwner,[sPersonID])) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nOops!\n\n"+NameURI(sPersonID)+" is Owner! Remove them as owner before you block them.\n",kID);
                return;
            }
        } else return;
        if (!~llListFindList(lPeople, [sPersonID])) lPeople += sPersonID;
        else {
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+NameURI(sPersonID)+" is already registered as "+sToken+".",kID);
            return;
        }
        if (sPersonID != g_sWearerID) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Building relationship...",g_sWearerID);
        if (sToken == "owner") {
            if (~llListFindList(g_lTrust,[sPersonID])) RemovePerson(sPersonID, "trust", kID, TRUE);
            if (~llListFindList(g_lBlock,[sPersonID])) RemovePerson(sPersonID, "block", kID, TRUE);
            llPlaySound(g_sDrop,1.0);
        } else if (sToken == "trust") {
            if (~llListFindList(g_lBlock,[sPersonID])) RemovePerson(sPersonID, "block", kID, TRUE);
            if (sPersonID != g_sWearerID) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Looks like "+NameURI(sPersonID)+" is someone you can trust!",g_sWearerID);
            llPlaySound(g_sDrop,1.0);
        }
        if (sToken == "owner") {
            if (sPersonID == g_sWearerID) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nOops!\n\n"+NameURI(sPersonID)+" doesn't belong on this list as the wearer of the %DEVICETYPE%. Instead try: /%CHANNEL% %PREFIX% vanilla on\n",kID);
                return;
            } else
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\n%WEARERNAME% belongs to you now.\n\nSee [http://www.opencollar.at/congratulations.html here] what that means!\n",sPersonID);
        }
        if (sToken == "trust")
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\n%WEARERNAME% seems to trust you.\n\nSee [http://www.opencollar.at/congratulations.html here] what that means!\n",sPersonID);
        llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + sToken + "=" + llDumpList2String(lPeople, ","), "");
        llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, g_sSettingToken + sToken + "=" + llDumpList2String(lPeople, ","), "");
        if (sToken=="owner") {
            g_lOwner = lPeople;
            if (g_lOwner) SayOwners();
        }
        else if (sToken=="trust") g_lTrust = lPeople;
        else if (sToken=="tempowner") g_lTempOwner = lPeople;
        else if (sToken=="block") g_lBlock = lPeople;
    }
}

SayOwners() {
    integer iCount = llGetListLength(g_lOwner);
    if (iCount) {
        integer index;
        string sMsg = "You belong to ";
        if (iCount == 1) sMsg += NameURI(llList2String(g_lOwner,0))+".";
        else if (iCount == 2)
            sMsg +=  NameURI(llList2String(g_lOwner,0))+" and "+NameURI(llList2Key(g_lOwner,1))+".";
        else {
            while (index < iCount-1 && index < 9) {
                sMsg += NameURI(llList2String(g_lOwner,index))+", ";
                index+=1;
            }
            if (iCount > 10) sMsg += NameURI(llList2String(g_lOwner,index))+" et al.";
            else sMsg += "and "+NameURI(llList2String(g_lOwner,index))+".";
        }
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+sMsg,g_sWearerID);
    }
}

integer in_range(key kID) {
    if (g_iLimitRange) {
        if (llVecDist(llGetPos(), llList2Vector(llGetObjectDetails(kID, [OBJECT_POS]), 0)) > 20)
            return FALSE;
    }
    return TRUE;
}

integer Auth(string sObjID) {
    string sID = (string)llGetOwnerKey(sObjID);
    integer iAuth;
    if (~llListFindList(g_lOwner+g_lTempOwner,[sID]) || (sID == g_sWearerID && g_iVanilla))
        iAuth = CMD_OWNER;
    else if (llGetListLength(g_lOwner+g_lTempOwner) == 0 && sID == g_sWearerID)
        iAuth = CMD_OWNER;
    else if (~llListFindList(g_lBlock, [sID]))
        iAuth = CMD_BLOCKED;
    else if (~llListFindList(g_lTrust, [sID]))
        iAuth = CMD_TRUSTED;
    else if (sID == g_sWearerID)
        iAuth = CMD_WEARER;
    else if (g_iOpenAccess) {
        if (in_range((key)sID))
            iAuth = CMD_GROUP;
        else
            iAuth = CMD_EVERYONE;
    } else if (g_iGroupEnabled && (string)llGetObjectDetails((key)sObjID, [OBJECT_GROUP]) == (string)g_kGroup && (key)sID != g_sWearerID)
        iAuth = CMD_GROUP;
    else if (llSameGroup(sID) && g_iGroupEnabled && sID != g_sWearerID) {
        if (in_range((key)sID))
            iAuth = CMD_GROUP;
        else
            iAuth = CMD_EVERYONE;
    } else
        iAuth = CMD_EVERYONE;
    return iAuth;
}

UserCommand(integer iAuth, string sStr, key kID, integer iRemenu) {
    string sMessage = llToLower(sStr);
    list lParams = llParseString2List(sStr, [" "], []);
    string sCommand = llToLower(llList2String(lParams, 0));
    string sAction = llToLower(llList2String(lParams, 1));
    if (sStr == "menu "+g_sSubMenu) AuthMenu(kID, iAuth);
    else if (sStr == "list") {
        if (iAuth == CMD_OWNER || kID == g_sWearerID) {
            integer iLength = ~llGetListLength(g_lOwner);
            string sOutput="";
            while (iLength < -1) {
                sOutput += "\n" + NameURI(llList2String(g_lOwner, ++iLength));
                if (llStringLength(sOutput) > 948) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Owners: "+sOutput,kID);
                    sOutput = "";
                }
            }
            if (sOutput) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Owners: "+sOutput,kID);
            else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Owners: none",kID);
            if (g_lTempOwner)
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Temporary Owner: "+"\n" + NameURI(llList2String(g_lTempOwner,0)),kID);
            iLength = ~llGetListLength(g_lTrust);
            sOutput = "";
            while (iLength < -1) {
                sOutput += "\n" + NameURI(llList2String(g_lTrust,++iLength));
                if (llStringLength(sOutput) > 948) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Trusted: "+sOutput,kID);
                    sOutput = "";
                }
            }
            if (sOutput) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Trusted: "+sOutput,kID);
            iLength = ~llGetListLength(g_lBlock);
            sOutput = "";
            while (iLength < -1) {
                sOutput += "\n" + NameURI(llList2String(g_lBlock,++iLength));
                if (llStringLength(sOutput) > 948) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Blocked: "+sOutput,kID);
                    sOutput = "";
                }
            }
            if (sOutput) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Blocked: "+sOutput,kID);
            if (g_kGroup) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Group: secondlife:///app/group/"+(string)g_kGroup+"/about",kID);
            if (g_iVanilla) sOutput = g_sFlavor+" Mode: enabled";
            else sOutput = g_sFlavor+" Mode: disabled";
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+sOutput,kID);
            sOutput="closed";
            if (g_iOpenAccess) sOutput="open";
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Public Access: "+ sOutput,kID);
        }
        else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        if (iRemenu) AuthMenu(kID, iAuth);
    } else if (sCommand == "hard" && sAction == "vanilla") {
        if (kID != g_sWearerID || iAuth != CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%", kID);
        else {
            sAction = llToLower(llList2String(lParams,2));
            if (sAction == "on") {
                g_iHardVanilla = TRUE;
                llMessageLinked(LINK_SAVE,LM_SETTING_SAVE,g_sSettingToken+"hardvanilla=1","");
            } else if (sAction == "off") {
                g_iHardVanilla = FALSE;
                llMessageLinked(LINK_SAVE,LM_SETTING_DELETE,g_sSettingToken+"hardvanilla","");
            }
            sStr = "off";
            if (g_iHardVanilla) sStr = "on";
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Hardvanilla is turned "+sStr+".", kID);
        }
    } else if (sCommand == "vanilla" || sCommand == llToLower(g_sFlavor)) {
        if ((iAuth == CMD_OWNER && !~llListFindList(g_lTempOwner,[(string)kID]))
            || (g_iHardVanilla && kID == g_sWearerID)) {
            if (g_iHardVanilla && kID != g_sWearerID) {
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%", kID);
                jump next;
            }
            if (sAction == "on") {
                g_iVanilla = TRUE;
                llMessageLinked(LINK_SAVE,LM_SETTING_SAVE,g_sSettingToken+"vanilla=1","");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Vanilla enabled.",kID);
            } else if (sAction == "off") {
                g_iVanilla = FALSE;
                llMessageLinked(LINK_SAVE,LM_SETTING_DELETE,g_sSettingToken+"vanilla","");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Vanilla disabled.",kID);
                if (iRemenu && kID == g_sWearerID) iAuth = Auth(kID);
            } else {
                sStr = "disabled.";
                if (g_iVanilla) sStr = "enabled.";
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Vanilla is currently "+sStr,kID);
            }

        } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%", kID);
        @next;
        if (iRemenu) AuthMenu(kID, iAuth);
    } else if (sMessage == "owners" || sMessage == "access") {
        AuthMenu(kID, iAuth);
    } else if (sCommand == "owner" && iRemenu==FALSE) {
        AuthMenu(kID, iAuth);
    } else if (sCommand == "add") {
        if (!~llListFindList(["owner","trust","block"],[sAction])) return;
        string sTmpID = llList2String(lParams,2);
        if (iAuth!=CMD_OWNER && !( sAction == "trust" && kID==g_sWearerID )) {
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
            if (iRemenu) AuthMenu(kID, Auth(kID));
        } else if ((key)sTmpID){
            AddUniquePerson(sTmpID, sAction, kID);
            if (iRemenu) Dialog(kID, "\nChoose who to add to the "+sAction+" list:\n",[sTmpID],[UPMENU],0,Auth(kID),"AddAvi"+sAction, TRUE);
        } else
            Dialog(kID, "\nChoose who to add to the "+sAction+" list:\n",[sTmpID],[UPMENU],0,iAuth,"AddAvi"+sAction, TRUE);
    } else if (sCommand == "remove" || sCommand == "rm") {
        if (!~llListFindList(["owner","trust","block"],[sAction])) return;
        string sTmpID = llDumpList2String(llDeleteSubList(lParams,0,1), " ");
        if (iAuth != CMD_OWNER && !( sAction == "trust" && kID == g_sWearerID )) {
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
            if (iRemenu) AuthMenu(kID, Auth(kID));
        } else if ((key)sTmpID) {
            RemovePerson(sTmpID, sAction, kID, FALSE);
            if (iRemenu) RemPersonMenu(kID, sAction, Auth(kID));
        } else if (llToLower(sTmpID) == "remove all") {
            RemovePerson(sTmpID, sAction, kID, FALSE);
            if (iRemenu) RemPersonMenu(kID, sAction, Auth(kID));
        } else RemPersonMenu(kID, sAction, iAuth);
     } else if (sCommand == "group") {
         if (iAuth==CMD_OWNER){
             if (sAction == "on") {
                if ((key)(llList2String(lParams, -1))) g_kGroup = (key)llList2String(lParams, -1);
                else g_kGroup = (key)llList2String(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]), 0);
                if (g_kGroup != "") {
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "group=" + (string)g_kGroup, "");
                    g_iGroupEnabled = TRUE;
                    llMessageLinked(LINK_RLV, RLV_CMD, "setgroup=n", "auth");
                    llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Group set to secondlife:///app/group/" + (string)g_kGroup + "/about\n\nNOTE: If RLV is enabled, the group slot has been locked and group mode has to be disabled before %WEARERNAME% can switch to another group again.\n",kID);
                }
            } else if (sAction == "off") {
                g_kGroup = "";
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sSettingToken + "group", "");
                g_iGroupEnabled = FALSE;
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Group unset.",kID);
                llMessageLinked(LINK_RLV, RLV_CMD, "setgroup=y", "auth");
            }
        } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        if (iRemenu) AuthMenu(kID, Auth(kID));
    } else if (sCommand == "public") {
        if (iAuth==CMD_OWNER){
            if (sAction == "on") {
                g_iOpenAccess = TRUE;
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "public=" + (string) g_iOpenAccess, "");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"The %DEVICETYPE% is open to the public.",kID);
            } else if (sAction == "off") {
                g_iOpenAccess = FALSE;
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sSettingToken + "public", "");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"The %DEVICETYPE% is closed to the public.",kID);
            }
        } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        if (iRemenu) AuthMenu(kID, Auth(kID));
    } else if (sCommand == "limitrange") {
        if (iAuth==CMD_OWNER){
            if (sAction == "on") {
                g_iLimitRange = TRUE;
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sSettingToken + "limitrange", "");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Public access range is limited.",kID);
            } else if (sAction == "off") {
                g_iLimitRange = FALSE;
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "limitrange=" + (string) g_iLimitRange, "");
                llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Public access range is simwide.",kID);
            }
        } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        if (iRemenu) AuthMenu(kID, Auth(kID));
    } else if (sMessage == "runaway"){
        if (kID == g_sWearerID) {
            if (g_iRunawayDisable)
                llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
            else {
                Dialog(kID, "\nDo you really want to run away from all owners?", ["Yes", "No"], [UPMENU], 0, iAuth, "runawayMenu",FALSE);
                return;
            }
        } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"This feature is only for the wearer of the %DEVICETYPE%.",kID);
        if (iRemenu) AuthMenu(kID, Auth(kID));
    } else if (sCommand == "flavor") {
        if (kID != g_sWearerID) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        else if (sAction) {
            g_sFlavor = llGetSubString(sStr,7,15);
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nYour new flavor is \""+g_sFlavor+"\".\n",kID);
            llMessageLinked(LINK_SAVE,LM_SETTING_SAVE,g_sSettingToken+"flavor="+g_sFlavor,"");
        } else
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nYour current flavor is \""+g_sFlavor+"\".\n\nTo set a new flavor type \"/%CHANNEL% %PREFIX% flavor MyFlavor\". Flavors must be single names and can only be a maximum of 9 characters.\n",kID);
    }
}

RunAway() {
    llMessageLinked(LINK_DIALOG,NOTIFY_OWNERS,"%WEARERNAME% ran away!","");
    llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, g_sSettingToken + "owner=", "");
    llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sSettingToken + "owner", "");
    llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, g_sSettingToken + "tempowner=", "");
    llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sSettingToken + "tempowner", "");
    llMessageLinked(LINK_ALL_OTHERS, CMD_OWNER, "clear", g_sWearerID);
    llMessageLinked(LINK_ALL_OTHERS, CMD_OWNER, "runaway", g_sWearerID);
    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Runaway finished.",g_sWearerID);
    llResetScript();
}

default {
    on_rez(integer iParam) {
        llResetScript();
    }

    state_entry() {
        if (llGetStartParameter()==825) llSetRemoteScriptAccessPin(0);
        else g_iFirstRun = TRUE;
        g_sWearerID = llGetOwner();
        if (!llSubStringIndex(llGetObjectDesc(),"LED")) g_iIsLED = TRUE;
        llMessageLinked(LINK_ALL_OTHERS,LINK_UPDATE,"LINK_REQUEST","");
    }

    link_message(integer iSender, integer iNum, string sStr, key kID) {
        if (iNum == CMD_ZERO) {
            if (g_iIsLED) {
                llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_FULLBRIGHT,ALL_SIDES,TRUE,PRIM_BUMP_SHINY,ALL_SIDES,PRIM_SHINY_NONE,PRIM_BUMP_NONE,PRIM_GLOW,ALL_SIDES,0.4]);
                llSetTimerEvent(0.22);
            }
            integer iAuth = Auth(kID);
            if (kID == g_sWearerID && sStr == "runaway") {
                if (g_iRunawayDisable)
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Runaway is currently disabled.",g_sWearerID);
                else
                    UserCommand(iAuth,"runaway",kID, FALSE);
            } else if (iAuth == CMD_OWNER && sStr == "runaway")
                UserCommand(iAuth, "runaway", kID, FALSE);
            else llMessageLinked(LINK_SET, iAuth, sStr, kID);
            return;
        } else if (iNum >= CMD_OWNER && iNum <= CMD_WEARER)
            UserCommand(iNum, sStr, kID, FALSE);
        else if (iNum == LM_SETTING_RESPONSE) {
            list lParams = llParseString2List(sStr, ["="], []);
            string sToken = llList2String(lParams, 0);
            string sValue = llList2String(lParams, 1);
            integer i = llSubStringIndex(sToken, "_");
            if (llGetSubString(sToken, 0, i) == g_sSettingToken) {
                sToken = llGetSubString(sToken, i + 1, -1);
                if (sToken == "owner")
                    g_lOwner = llParseString2List(sValue, [","], []);
                else if (sToken == "tempowner")
                    g_lTempOwner = [sValue];
                else if (sToken == "vanilla") g_iVanilla = (integer)sValue;
                else if (sToken == "group") {
                    g_kGroup = (key)sValue;
                    if (g_kGroup != "") {
                        if ((key)llList2String(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]), 0) == g_kGroup) g_iGroupEnabled = TRUE;
                        else g_iGroupEnabled = FALSE;
                    } else g_iGroupEnabled = FALSE;
                }
                else if (sToken == "public") g_iOpenAccess = (integer)sValue;
                else if (sToken == "limitrange") g_iLimitRange = (integer)sValue;
                else if (sToken == "norun") g_iRunawayDisable = (integer)sValue;
                else if (sToken == "trust") g_lTrust = llParseString2List(sValue, [","], [""]);
                else if (sToken == "block") g_lBlock = llParseString2List(sValue, [","], [""]);
                else if (sToken == "flavor") g_sFlavor = sValue;
                else if (sToken == "hardvanilla") g_iHardVanilla = (integer)sValue;
            } else if (sStr == "settings=sent") {
                if (g_iFirstRun) {
                    if (g_lOwner) SayOwners();
                    if (g_iVanilla)
                        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"At the moment your %DEVICETYPE% is configured for you to remain in control at all times. If you don't want that, you can disable Vanilla Mode to relinquish control to only your owners: /%CHANNEL% %PREFIX% vanilla off",g_sWearerID);
                    g_iFirstRun = FALSE;
                }
            }
        } else if (iNum == AUTH_REQUEST) {
            llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_FULLBRIGHT,ALL_SIDES,TRUE,PRIM_BUMP_SHINY,ALL_SIDES,PRIM_SHINY_NONE,PRIM_BUMP_NONE,PRIM_GLOW,ALL_SIDES,0.4]);
            llSetTimerEvent(0.22);
            llMessageLinked(iSender,AUTH_REPLY, "AuthReply|"+(string)kID+"|"+(string)Auth(kID), llGetSubString(sStr,0,35));
        } else if (iNum == DIALOG_RESPONSE) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            if (~iMenuIndex) {
                llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_FULLBRIGHT,ALL_SIDES,TRUE,PRIM_BUMP_SHINY,ALL_SIDES,PRIM_SHINY_NONE,PRIM_BUMP_NONE,PRIM_GLOW,ALL_SIDES,0.4]);
                llSetTimerEvent(0.22);
                list lMenuParams = llParseString2List(sStr, ["|"], []);
                key kAv = (key)llList2String(lMenuParams, 0);
                string sMessage = llList2String(lMenuParams, 1);
                integer iAuth = (integer)llList2String(lMenuParams, 3);
                string sMenu=llList2String(g_lMenuIDs, iMenuIndex + 1);
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);
                if (sMenu == "Auth") {
                    if (sMessage == UPMENU)
                        llMessageLinked(LINK_ALL_OTHERS, iAuth, "menu " + g_sParentMenu, kAv);
                    else {
                        list lTranslation=[
                            "+ Owner","add owner",
                            "+ Trust","add trust",
                            "+ Block","add block",
                            "− Owner","rm owner",
                            "− Trust","rm trust",
                            "− Block","rm block",
                            "Group ☐","group on",
                            "Group ☑","group off",
                            "Public ☐","public on",
                            "Public ☑","public off",
                            g_sFlavor+" ☐","vanilla on",
                            g_sFlavor+" ☑","vanilla off",
                            "Access List","list",
                            "Runaway","runaway"
                          ];
                        integer buttonIndex=llListFindList(lTranslation,[sMessage]);
                        if (~buttonIndex)
                            sMessage=llList2String(lTranslation,buttonIndex+1);
                        UserCommand(iAuth, sMessage, kAv, TRUE);
                    }
                } else if (sMenu == "removeowner" || sMenu == "removetrust" || sMenu == "removeblock" ) {
                    string sCmd = "rm "+llGetSubString(sMenu,6,-1)+" ";
                    if (sMessage == UPMENU)
                        AuthMenu(kAv, iAuth);
                    else UserCommand(iAuth, sCmd +sMessage, kAv, TRUE);
                } else if (sMenu == "runawayMenu" ) {
                    if (sMessage == "Yes") RunAway();
                    else if (sMessage == UPMENU) AuthMenu(kAv, iAuth);
                    else if (sMessage == "No") llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Runaway aborted.",kAv);
                } if (llSubStringIndex(sMenu,"AddAvi") == 0) {
                    if ((key)sMessage)
                        AddUniquePerson(sMessage, llGetSubString(sMenu,6,-1), kAv);
                    else if (sMessage == "BACK")
                        AuthMenu(kAv,iAuth);
                }
            }
        } else if (iNum == DIALOG_TIMEOUT) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);
        } else if (iNum == LOADPIN && ~llSubStringIndex(llGetScriptName(),sStr)) {
            integer iPin = (integer)llFrand(99999.0)+1;
            llSetRemoteScriptAccessPin(iPin);
            llMessageLinked(iSender, LOADPIN, (string)iPin+"@"+llGetScriptName(),llGetKey());
        } else if (iNum == BUILD_REQUEST)
            llMessageLinked(iSender,iNum+g_iBuild,llGetScriptName(),"");
        else if (iNum == LINK_UPDATE) {
            if (sStr == "LINK_DIALOG") LINK_DIALOG = iSender;
            else if (sStr == "LINK_RLV") LINK_RLV = iSender;
            else if (sStr == "LINK_SAVE") LINK_SAVE = iSender;
            else if (sStr == "LINK_REQUEST") llMessageLinked(LINK_ALL_OTHERS,LINK_UPDATE,"LINK_AUTH","");
        } else if (iNum == REBOOT && sStr == "reboot") llResetScript();
    }

    timer () {
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_FULLBRIGHT,ALL_SIDES,FALSE,PRIM_BUMP_SHINY,ALL_SIDES,PRIM_SHINY_HIGH,PRIM_BUMP_NONE,PRIM_GLOW,ALL_SIDES,0.0]);
        llSetTimerEvent(0.0);
    }
}
