# styles.py
# This module contains functions related to styles generation


def generate_style(event):
    """Generates CSS styles for the HTML email."""
    style = f"""<style>
    @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');

    body {{
        font-family: 'Roboto', sans-serif;
        background-color: #f7f8fc;
        line-height: 1.6;
    }}
    .container {{
        border: 1px solid #e3e7ed;
        padding: 20px;
        max-width: 600px;
        margin: 40px auto;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }}
    .header {{
        text-align: center;
        font-weight: bold;
        font-size: 24px;
        margin-bottom: 30px;
        color: #161A30;
    }}
    .section {{
        border: 1px solid #e3e7ed;
        padding: 15px;
        margin-bottom: 15px;
        border-radius: 5px;
    }}
    .section-title {{
        background-color: #161A30;
        color: white;
        padding: 10px;
        border-radius: 3px;
        font-weight: bold;
        margin-bottom: 15px;
    }}
    .value {{
        color: #161A30;
        font-weight: bold;
    }}
    .ip-links {{
        text-align: right;
        margin-top: -10px;
    }}
    .ip-links a {{
        display: inline-block;
        margin-left: 10px;
        color: #fff;
        background-color: #5cb85c;
        padding: 5px 10px;
        border-radius: 3px;
        font-weight: bold;
        text-decoration: none;
    }}
    .ip-links a:hover {{
        background-color: #4cae4c;
    }}
    a.go-to-finding-btn, a.go-to-finding-btn:visited, a.go-to-finding-btn:link {{
        color: #fff !important;
        background-color: #e47911;
        padding: 8px 16px;
        border-radius: 3px;
        font-weight: bold;
        text-decoration: none;
        display: inline-block;
        margin-top: 10px;
    }}
    a.go-to-finding-btn:hover {{
        background-color: #a6611e;
    }}
    table {{
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 15px;
    }}
    th {{
        background-color: #4e5d6c;
        color: white;
        padding: 12px;
        text-align: left;
    }}
    td {{
        border: 1px solid #e3e7ed;
        padding: 10px;
    }}
    @media (max-width: 600px) {{
        .container {{
            padding: 10px;
            margin: 10px;
        }}
        .header {{
            font-size: 20px;
        }}
    }}
</style>
    """
    return style