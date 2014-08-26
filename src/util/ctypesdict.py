#!/usr/bin/python3.3

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

'''
Recursively set the members of a ctypes struct from a dict.
Discards any dict members that do not exist in the struct,
and preserves the value of any struct members that do not exist in the dict.
'''
def setfromdict(struct, theDict):
    for fieldName, _ in struct._fields_:
        if fieldName in theDict:
            fieldAttr = getattr(struct, fieldName)
            if hasattr(fieldAttr, "_length_") and hasattr(fieldAttr, "_type_"):
                # Probably an array
                for i in range(fieldAttr._length_):
                    fieldAttr[i] = theDict[fieldName][i]
            elif hasattr(fieldAttr, "_fields_"):
                # Probably another struct - recurse
                setfromdict(fieldAttr, theDict[fieldName])
            else:
                setattr(struct, fieldName, theDict[fieldName])
                fieldAttr = theDict[fieldName]
