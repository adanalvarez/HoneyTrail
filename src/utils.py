def get_nested_value(dict_obj, key_list):
    """Retrieves a nested value from a dictionary based on a list of keys."""
    for key in key_list:
        dict_obj = dict_obj.get(key, {})
    return dict_obj