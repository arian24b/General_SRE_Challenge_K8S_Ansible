from dataclasses import dataclass
from ipaddress import IPv4Address, IPv6Address


@dataclass
class IpData:
    ip: IPv4Address | IPv6Address
    country: str
    cached: bool
