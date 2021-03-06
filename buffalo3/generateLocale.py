################################################################################
# Description: Constructs locale files for WoW addons using AceLocale-3.0
# Requires: A toc file in the current working directory
# Usage: Just run it from where your toc file lies. In the toc file,
#        there should be a list of all your lua source files and a list of
#        locale files in the format somePath/abXY.lua (for example
#        "locales/enUS.lua", the directory is optional)
#        In your source files, you have to use the variable L to index your
#        locale, i.e. L["Translate me!"]
# Author: Nimbal
# Date: $Date$
# Revision: $Revision$
# Legal blurp:
#   You may use, modify and redistribute this script freely as long as you
#   give credit to all previous authors and don't charge money for it
################################################################################

import os
import re
import sys
import codecs
import string

ADDON_NAME = "Buffalo3"
BASE_LOCALE = "enUS"
PLACEHOLDER = u"UNTRANSLATED"

def getRequiredTranslations(files):
    """
    Searches all given files for the pattern 'L["XYZ"]' and returns a
    dictionary with the XYZ as keys and "true" as values
    """
    regex = re.compile('L\["([^\]]*)"\]')
    required_translations = {}
    for filename in files:
        try:
            f = codecs.open(filename, 'r', 'utf-8')
            for line in f:
                s = regex.findall(line)
                for match in s:
                    required_translations[match] = u"true"
            f.close()
        except:
            pass
    return required_translations

def getExistingTranslationsInFile(filename):
    """
    Searches the given file for the pattern
        L["XYZ"] = "ABC"
    and returns a dictionary with the XYZ as keys and the ABC as values
    """
    regex = re.compile('L\["([^"]*)"\]\s*=\s*"([^"]*)"')
    existing_translations = {}
    try:
        f = codecs.open(filename, 'r', 'utf-8')
    except IOError:
        f = open(filename, 'w')
        f.close()
        return {}
    else:
        for line in f:
            s = regex.findall(line)
            if s and s[0][1] != PLACEHOLDER:
                existing_translations[s[0][0]] = s[0][1]
        f.close()
        return existing_translations

def setDifference(set1, set2):
    """
    Returns set1 \ set2 in terms of keys
    """
    difference = {}
    set1_keys = set1.keys()
    for key in set1_keys:
        if not set2.has_key(key):
            difference[key] = set1[key]
    return difference

def getUntranslatedEntries(base_locale, target_locale):
    """
    Returns all entries in base_locale that haven't been translated into
    target_locale yet
    """
    return setDifference(base_locale, target_locale)

def getObsoleteEntries(base_locale, target_locale):
    """
    Returns all entries in target_locale that are probably obsolete because
    they don't have an equivalent in base_locale
    """
    return setDifference(target_locale, base_locale)

def writeBaseLocale(base_locale, filename):
    """
    The base locale needs some truth
    """
    f = codecs.open(filename, 'w', 'utf-8')
    f.write(u'local L = LibStub("AceLocale-3.0"):NewLocale("'+ADDON_NAME+'", "'+BASE_LOCALE+'", true)\n')
    f.write(u'if not L then return end\n\n')
    f.write(u'-- Please do not edit this file directly, run generateLocale.py instead!\n')    
    items = base_locale.items()
    items.sort()
    f.write(u''.join([u'L["%s"] = true\n' % entry for entry, translation in items]))
    f.close()

def writeLocale(base_locale, filename):
    """
    Analyses the file, compares it with the base locale and rewrites the file
    accordingly
    """
    m = re.findall(r'([a-z][a-z][A-Z][A-Z])\.lua$', filename)
    locale_name = m[0]
    if locale_name == BASE_LOCALE:
        writeBaseLocale(base_locale, filename)
        return
    existing_translations = getExistingTranslationsInFile(filename)
    untranslated_entries = getUntranslatedEntries(base_locale, existing_translations)
    obsolete_entries = getObsoleteEntries(base_locale, existing_translations)
    needed_entries = setDifference(existing_translations, obsolete_entries)
    f = codecs.open(filename, 'w', 'utf-8')
    f.write(u'local L = LibStub("AceLocale-3.0"):NewLocale("'+ADDON_NAME+'", "'+locale_name+'")\n')        
    f.write(u'if not L then return end\n\n')
    f.write(u'-- Untranslated entries -- \n')
    # Sorry for the formatting here
    f.write(u'''-- Don\'t worry about arranging them alphabetically with the existing
-- translations or even uncommenting them, they will be sorted and uncommented
-- automatically the next time the locales are built.\n''')
    f.write(u'-- Thank you for your contribution!\n')
    items = untranslated_entries.items()
    items.sort()
    f.write(u''.join([u'-- L["%s"] = "%s"\n' % (entry, PLACEHOLDER) for entry, translation in items]))
    f.write(u'\n')
    f.write(u'-- Obsolete entries --\n')
    f.write(u'-- These can probably be safely removed as they aren\'t present in the base locale anymore.\n-- If you are unsure, leave them, please.\n')
    items = obsolete_entries.items()
    items.sort()
    f.write(u''.join([u'-- L["%s"] = "%s"\n' % (entry, translation) for entry, translation in items]))
    f.write(u'\n')
    f.write(u'-- Translations --\n')
    f.write(u'-- These should only be changed if they are incorrect or inaccurate\n')
    items = needed_entries.items()
    items.sort()
    f.write(u''.join([u'L["%s"] = "%s"\n' % (entry, translation) for entry, translation in items]))
    f.close()

def scanTOC():
    """
    Scans the TOC file for source files and locale files
    """
    f = open(ADDON_NAME + '.toc', 'r')
    metadata = re.compile(r'^##')
    lua_file = re.compile(r'.lua$')
    locale_file = re.compile(r'[a-z][a-z][A-Z][A-Z]\.lua$')
    locale_list = []
    lua_source_list = []
    for line in f:
        if metadata.match(line):
            continue
        if lua_file.findall(line):
            if locale_file.findall(line):
                locale_list.append(string.strip(line,'\n'))
            else:
                lua_source_list.append(string.strip(line,'\n'))
    return lua_source_list, locale_list

lua_files, locale_files = scanTOC()
base_locale = getRequiredTranslations(lua_files)
for filename in locale_files:
    writeLocale(base_locale, filename)

