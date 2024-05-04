import html
from utils import get_nested_value
import logging

def generate_cloudtrail_information_section(finding):
    """Generates HTML section with CloudTrail information."""

    def add_section(label, *keys):
        """Adds a section to the HTML output if the specified keys exist in the finding."""
        data = []
        for value in finding["Records"]:
            for key in keys:
                if isinstance(value, dict) and key in value:
                    value = value[key]
                else:
                    logging.info(f"Key not found: {key}")
                    return

            safe_value = html.escape(str(value))
            data.append(safe_value)
        data_comma_separated =  ', '.join(data)
        sections.append(
                f"<div>{label}: <span class='value'>{data_comma_separated}</span></div>"
        )

    sections = []

    # Standard sections
    add_section("User Identity type", "userIdentity", "type")
    add_section("User Identity Principal ID", "userIdentity", "principalId")
    add_section("User Identity ARN", "userIdentity", "arn")
    add_section("User Identity account", "userIdentity", "accountId")
    add_section("User Identity accessKeyId", "userIdentity", "accessKeyId")
    add_section("Event Time", "eventTime")
    add_section("AWS Account", "recipientAccountId")
    add_section("Region", "awsRegion")
    add_section("Event", "eventName")
    add_section("Source", "eventSource")
    add_section("Event Time", "eventTime")
    add_section("Resources", "resources")

    # Convert the sections into div elements
    sections_html = f"""
        <div class="section">
            <div class="section-title">CloudTrail Information</div>
            {"".join(sections)}
        </div>
        """
    return sections_html