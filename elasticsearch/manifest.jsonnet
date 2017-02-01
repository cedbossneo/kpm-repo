local kpm = import "kpm.libjsonnet";

function(
  params={}
)

  kpm.package({
    package: {
      name: "wescale/elasticsearch",
      expander: "jinja2",
      author: "Cedric Hauber",
      version: "1.0.0",
      description: "elasticsearch",
      license: "Apache 2.0",
    },

    variables: {
      es: {
        client_size: 2,
        master_size: 3,
        data_size: 3,
        cluster_name: "demo",
        image: "cedbossneo/elasticsearch:1.7.5"
      }
    },

    resources: [
      {
        file: "es-client.yaml",
        template: (importstr "templates/es-client.yaml.j2"),
        name: "es-client",
        type: "deployment"
      },
      {
        file: "es-master.yaml",
        template: (importstr "templates/es-master.yaml.j2"),
        name: "es-master",
        type: "deployment"
      },
      {
        file: "es-data.yaml",
        template: (importstr "templates/es-data.yaml.j2"),
        name: "es-data",
        type: "statefulset"
      },
      {
        file: "es-svc-discovery.yaml",
        template: (importstr "templates/es-svc-discovery.yaml.j2"),
        name: "elasticsearch-discovery",
        type: "service"
      },
      {
        file: "es-svc-internal.yaml",
        template: (importstr "templates/es-svc-internal.yaml.j2"),
        name: "elasticsearch-internal",
        type: "service"
      },
      {
        file: "es-svc-lb.yaml",
        template: (importstr "templates/es-svc-lb.yaml.j2"),
        name: "elasticsearch-lb",
        type: "service"
      },
      {
        file: "es-svc-data.yaml",
        template: (importstr "templates/es-svc-data.yaml.j2"),
        name: "elasticsearch-data",
        type: "service"
      },
      {
        file: "pv-master.yaml",
        template: (importstr "templates/pv-master.yaml.j2"),
        type: "persistentvolume",
        name: std.format("es-%s-master", [$.variables.es.cluster_name]),
        sharded: "master"
      },
      {
        file: "pv-data.yaml",
        template: (importstr "templates/pv-data.yaml.j2"),
        type: "persistentvolume",
        name: std.format("es-%s-data", [$.variables.es.cluster_name]),
        sharded: "data"
      }
    ],

    shards: {
      master: $.variables.es.master_size,
      data: $.variables.es.data_size
    },

    deploy: [
        { name: "$self"},
    ]


  }, params)
