#!/usr/bin/python3.3

import ctypes

# Thanks to http://stackoverflow.com/users/156771/tamas
def getdict(struct):
    result = {}
    for field, _ in struct._fields_:
        value = getattr(struct, field)
        if hasattr(value, "_length_") and hasattr(value, "_type_"):
            # Probably an array
            value = list(value)
        elif hasattr(value, "_fields_"):
            # Probably another struct
            value = getdict(value)
        result[field] = value
    return result

def setfromdict(struct, dict):
    for fieldName, _ in struct._fields_:
        fieldAttr = getattr(struct, fieldName)
        if hasattr(fieldAttr, "_length_") and hasattr(fieldAttr, "_type_"):
            # Probably an array
            for i in range(fieldAttr._length_):
                fieldAttr[i] = dict[fieldName][i]
        elif hasattr(fieldAttr, "_fields_"):
            # Probably another struct - recurse
            setfromdict(fieldAttr, dict[fieldName])
        else:
            fieldAttr = dict[fieldName]
