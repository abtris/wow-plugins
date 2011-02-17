-- TradeSkillMaster_AuctionDB Locale - frFR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "frFR")
if not L then return end

L["%s has a market value of %s and was seen %s times last scan and %s times total. The stdDev is %s."] = "La valeur de marché de %s est de %s. Il a été vu %s fois à la dernière analyse et %s fois au total. Le stdDev est %s."
L["Alchemy"] = "Alchimie"
L["Auction house must be open in order to scan."] = "L’hôtel des vente doit être ouvert pour pouvoir lancer l'analyse."
L["AuctionDB"] = "AuctionDB"
L["AuctionDB - Auction House Scanning"] = "AuctionDB - Analyse de l’hôtel des vente"
L["AuctionDB - Run Scan"] = "AuctionDB - Lancer une analyse"
L["AuctionDB - Scanning"] = "AuctionDB - Analyse en cours"
L["AuctionDB Market Value:"] = "AuctionDB - Valeur du marché:"
L["AuctionDB Min Buyout:"] = "AuctionDB - Prix Minimum:"
L["AuctionDB Seen Count:"] = "AuctionDB - Nbr de vue:"
L["Blacksmithing"] = "Forge"
L["Complete AH Scan"] = "Analyse complète"
L["Cooking"] = "Cuisine"
L["Enable display of AuctionDB data in tooltip."] = "Activé l'affichage des données d'AuctionDB dans les tooltip."
L["Enchanting"] = "Enchantement"
L["Engineering"] = "Ingénierie"
L["Error: AuctionHouse window busy."] = "Erreur: Fenêtre de l’hôtel des ventes occupé."
L["GetAll Scan:"] = "Analyse complète:"
L[ [=[If checked, a GetAll scan will be used whenever possible.

WARNING: With any GetAll scan there is a risk you may get disconnected from the game.]=] ] = [=[Si coché, une analyse complète sera effectué dès que possible.

ATTENTION: Une analyse complète de l'HV risque de vous déconnecter du jeu.]=]
L["If checked, a regular scan will scan for this profession."] = "Si coché, cette profession sera analysé."
L["Inscription"] = "Caligraphie"
L["Item Lookup:"] = "Chercher d'un objet:"
L["Jewelcrafting"] = "Joaillerie"
L["Leatherworking"] = "Travail du Cuir"
L["No data for that item"] = "Aucune donnée pour cet objet"
L["Not Ready"] = "Pas prêt"
L["Nothing to scan."] = "Rien à analyser."
L["Professions to scan for:"] = "Professions à analyser:"
L["Ready"] = "Prêt"
L["Ready in %s min and %s sec"] = "Prêt dans %s min et %s sec"
L["Run GetAll Scan"] = "Lancer une analyse complète"
L["Run GetAll Scan if Possible"] = "Lancer une analyse complète si possible"
L["Run Regular Scan"] = "Lancer une analyse normale"
L["Run Scan"] = "Lancer une analyse"
L["Scan complete!"] = "Analyse terminée!"
L["Scan interupted due to auction house being closed."] = "Analyse interrompue (l’hôtel des vent a été fermé)."
L[ [=[Starts scanning the auction house based on the below settings.

If you are running a GetAll scan, your game client may temporarily lock up.]=] ] = [=[Commence une analyse de l’hôtel des vente basé sur les paramètres ci-dessous.

Si vous lancez une analyse complète, votre jeu peut se figer quelques instants.]=]
L["Tailoring"] = "Couture"
L["resets the data"] = "Réinitialiser les donnéees"
L["|cffff0000WARNING:|r As of 4.0.1 there is a bug with GetAll scans only scanning a maximum of 42554 auctions from the AH which is less than your auction house currently contains. As a result, thousands of items may have been missed. Please use regular scans until blizzard fixes this bug."] = "|cffff0000ATTENTION:|r Depuis la 4.0.1, il y a un bug avec l'analyse complète. Elle ne peut analyser que 42554 ventes depuis l'HV, ce qui est moins que ce que votre HV contient actuellement. Résultat: Des milliers d'objets peuvent avoir été oublié. Merci d'utiliser les analyses normales en attendant une correction de Blizzard."
