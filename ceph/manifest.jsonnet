local kpm = import "kpm.libjsonnet";

function(
  params={}
)

  kpm.package({
    package: {
      name: "wescale/ceph",
      expander: "jinja2",
      author: "Cedric Hauber",
      version: "1.0.0",
      description: "CEPH Cluster",
      license: "Apache 2.0"
    },

    variables: {
      keyring: {
        mds: "AQAPxSpYAAAAABAASncm+os/+m2c45fp29MUNw==",
        osd: "AQAPxSpYAAAAABAA/QVfOwJ5AwY/k0mTLsFB+g==",
        rgw: "AQAPxSpYAAAAABAAdKXFW6cwGA71BQKQTmgPtA==",
        client: "",
        mon: "AQAPxSpYAAAAABAApgvLdfGtVJYS7S+SkbfcbA==",
        admin: "AQAPxSpYAAAAABAA5Wb8gTsPqyg9STU7uE6Diw==",
      },
      conf: ""
    },

    resources: [
      {
        file: "ceph-mds-v1-dp.yaml",
        template: (importstr "templates/ceph-mds-v1-dp.yaml.j2"),
        name: "ceph-mds",
        type: "deployment"
      },
      {
        file: "ceph-mon-v1-svc.yaml",
        template: (importstr "templates/ceph-mon-v1-svc.yaml.j2"),
        name: "ceph-mon",
        type: "service"
      },
      {
        file: "ceph-mon-v1-sfs.yaml",
        template: (importstr "templates/ceph-mon-v1-sfs.yaml.j2"),
        name: "ceph-mon",
        type: "statefulset"
      },
      {
        file: "ceph-mon-check-v1-dp.yaml",
        template: (importstr "templates/ceph-mon-check-v1-dp.yaml.j2"),
        name: "ceph-mon-check",
        type: "deployment"
      },
      {
        file: "ceph-osd-v1-svc.yaml",
        template: (importstr "templates/ceph-osd-v1-svc.yaml.j2"),
        name: "ceph-osd",
        type: "service"
      },
      {
        file: "ceph-osd-v1-sfs.yaml",
        template: (importstr "templates/ceph-osd-v1-sfs.yaml.j2"),
        name: "ceph-osd",
        type: "statefulset"
      },
      {
        file: "gce-sc.yaml",
        template: (importstr "templates/gce-sc.yaml.j2"),
        name: "gce",
        type: "storageclass"
      },
      {
        file: "ceph-conf-combined.yaml",
        template: (importstr "templates/ceph-conf-combined.yaml.j2"),
        name: "ceph-conf-combined",
        type: "secret"
      },
      {
        file: "ceph-bootstrap-rgw-keyring.yaml",
        template: (importstr "templates/ceph-bootstrap-rgw-keyring.yaml.j2"),
        name: "ceph-bootstrap-rgw-keyring",
        type: "secret"
      },
      {
        file: "ceph-bootstrap-mds-keyring.yaml",
        template: (importstr "templates/ceph-bootstrap-mds-keyring.yaml.j2"),
        name: "ceph-bootstrap-mds-keyring",
        type: "secret"
      },
      {
        file: "ceph-bootstrap-osd-keyring.yaml",
        template: (importstr "templates/ceph-bootstrap-osd-keyring.yaml.j2"),
        name: "ceph-bootstrap-osd-keyring",
        type: "secret"
      },
      {
        file: "ceph-client-key.yaml",
        template: (importstr "templates/ceph-client-key.yaml.j2"),
        name: "ceph-client-key",
        type: "secret"
      },
      {
        file: "ceph-tools.yaml",
        template: (importstr "templates/ceph-tools.yaml.j2"),
        name: "ceph-tools",
        type: "deamonset"
      }
    ],

    deploy: [
        { name: "$self"},
    ]


  }, params)
