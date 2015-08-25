'''
Created on Oct 3, 2013

@author: gcardwel
'''
import os
import sys

def loadPlugins():
    local_dir = os.path.dirname(os.path.realpath(__file__))
    plugin_dir = os.path.join(os.path.dirname(local_dir),"plugins")
    sys.path.insert(0, plugin_dir)
    plugin_files = [x[:-3] for x in os.listdir(plugin_dir) if x.endswith(".py")]
    for plugin in plugin_files:
        __import__(plugin)
         
