import os
import configparser
from jinja2 import Environment, FileSystemLoader


def main():
    cp = configparser.ConfigParser()
    cp.read("./hosts")
    all_vars = cp["all:vars"]
    vars = {
        "scale_tier": all_vars["scale_tier"].strip('"'),
        "router_name_suffix": all_vars["router_name_suffix"].strip('"'),
        "primary_ip": all_vars["primary_ip"].strip('"'),
        "backup_ip": all_vars["backup_ip"].strip('"'),
        "monitoring_ip": all_vars["monitoring_ip"].strip('"'),
        "vmr_version": {"stdout": "solace/solace-pubsub-standard"},
    }

    filename = "./roles/ha/templates/ha-create.sh.j2"
    filedir = os.path.dirname(os.path.abspath(filename))
    filename = os.path.basename(filename)
    e = Environment(
        loader=FileSystemLoader(filedir), trim_blocks=True, lstrip_blocks=True
    )
    template = e.get_template(filename)

    roles = ["primary", "backup", "monitoring"]
    for role in roles:
        vars["ha_role"] = role
        docker_script = template.render(vars)
        print("{:-^80}".format(role))
        print(docker_script)


if __name__ == "__main__":
    main()
