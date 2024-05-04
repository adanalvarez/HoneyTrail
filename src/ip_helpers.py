from utils import get_nested_value
import logging
import requests

def get_ip_information_section(event, api_key):
    """Retrieves IP information based on various paths from the event and formats it."""
    value = event["Records"][0]
    ip_address_v4 = value["sourceIPAddress"]
    logging.info(f"External IP: {ip_address_v4}")
    if api_key and ip_address_v4:
        ip_info = get_ip_information(ip_address_v4, api_key)
        return (
            (format_ip_information(ip_address_v4, ip_info), ip_address_v4)
            if ip_info
            else ("", None)
        )

    return "", None


def format_ip_information(ip, data):
    """Formats IP information into HTML."""
    if "is a private IP address" in str(data):
        logging.info("Private IP address found.")
        sections_html = f"""
           <div class="section">
                <div class="section-title">IP Information</div>
                <div>IP Address: <span class="value">{ip}</span></div>
                <div>Private IP address</div>
            </div>
            """
    else:
        security_indicators = ", ".join(
            [key.upper() for key, value in data["security"].items() if value]
        )
        maps_url = f"https://www.google.com/maps/search/{data['location']['latitude']},{data['location']['longitude']}"
        virustotal_url = f"https://www.virustotal.com/gui/ip-address/{ip}"
        greynoise_url = f"https://viz.greynoise.io/ip/{ip}"
        sections_html = f"""
        <div class="section">
                <div class="section-title">IP Information</div>
                <div class="ip-links">
                    <a href="{virustotal_url}" target="_blank">VirusTotal</a>
                    <a href="{greynoise_url}" target="_blank">GreyNoise</a>
                </div>
                <div>IP Address: <span class="value">{data['ip']}</span></div>
                <div>Country: <span class="value">{data['location']['country']}</span></div>
                <div>City/Region: <span class="value">{data['location']['city']}/{data['location']['region']}</span></div>
                <div>Continent: <span class="value">{data['location']['continent']}</span></div>
                <div>Geolocation: <a href="{maps_url}" target="_blank"><span class="value">{data['location']['latitude']}, {data['location']['longitude']}</span></a></div>
                <div>Time Zone: <span class="value">{data['location']['time_zone']}</span></div>
                <div>Is in European Union: <span class="value">{'Yes' if data['location']['is_in_european_union'] else 'No'}</span></div>
                <div>Security Indicators: <span class="value">{security_indicators}</span></div>
                <div>Network Range: <span class="value">{data['network']['network']}</span></div>
                <div>Autonomous System: <span class="value">{data['network']['autonomous_system_organization']} ({data['network']['autonomous_system_number']})</span></div>
        </div>
        """
    return sections_html


def get_ip_information(ip, api_key):
    """Fetches IP information from vpnapi.io API."""
    url = f"https://vpnapi.io/api/{ip}?key={api_key}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        logging.info(f"Information from VPN API obtained.")
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Failed to retrieve IP information: {e}")
        return None