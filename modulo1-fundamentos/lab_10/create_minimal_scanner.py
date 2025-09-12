#!/usr/bin/env python3

from gvm.connections import UnixSocketConnection
from gvm.protocols.gmp import Gmp
from gvm.transforms import EtreeTransform

# Connection to GVM daemon
connection = UnixSocketConnection(path='/run/gvmd/gvmd.sock')
transform = EtreeTransform()

# Create scanner without depending on OSPD
def create_basic_scanner(gmp):
    try:
        # Create a basic CVE scanner (doesn't require full VT loading)
        scanner_xml = '''
        <create_scanner>
            <name>Basic Scanner</name>
            <host>127.0.0.1</host>
            <port>22</port>
            <type>1</type>
            <comment>Basic scanner for demonstration</comment>
        </create_scanner>
        '''
        
        response = gmp.send_command(scanner_xml)
        print("Scanner creation response:", response)
        
    except Exception as e:
        print(f"Error creating scanner: {e}")

# Create a simple target
def create_target(gmp):
    try:
        target_xml = '''
        <create_target>
            <name>Metasploitable Target</name>
            <hosts>172.20.0.27</hosts>
            <comment>Metasploitable vulnerable target</comment>
        </create_target>
        '''
        
        response = gmp.send_command(target_xml)
        print("Target creation response:", response)
        
    except Exception as e:
        print(f"Error creating target: {e}")

# Main execution
if __name__ == "__main__":
    with Gmp(connection=connection, transform=transform) as gmp:
        # Authenticate
        gmp.authenticate('admin', 'CyberSec123!')
        
        print("Creating basic scanner...")
        create_basic_scanner(gmp)
        
        print("Creating target...")
        create_target(gmp)
        
        print("Configuration complete!")