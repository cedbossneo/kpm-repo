local kpm = import "kpm.libjsonnet";

function(
  params={}
)

  kpm.package({
    package: {
      name: "wescale/concourse",
      expander: "jinja2",
      author: "Cedric Hauber",
      version: "2.6.0",
      description: "concourse",
      license: "Apache 2.0"
    },

    variables: {
      concourse_version: "2.6.0",
      db_password: "concourse",
      db_user: "concourse",
      db_name: "concourse"
    },

    resources: [
      {
        file: "keys.yaml",
        template: (importstr "templates/keys.yaml.j2"),
        name: "concourse-keys",
        type: "secret"
      },
      {
        file: "service.yaml",
        template: (importstr "templates/service.yaml.j2"),
        name: "concourse-web",
        type: "service"
      },
      {
        file: "service.yaml",
        template: (importstr "templates/service-workers.yaml.j2"),
        name: "concourse-worker",
        type: "service"
      },
      {
        file: "web.yaml",
        template: (importstr "templates/web.yaml.j2"),
        name: "concourse-web",
        type: "deployment"
      },
      {
        file: "pv.yaml",
        template: (importstr "templates/pv.yaml.j2"),
        name: "concourse",
        type: "persistentvolume"
      },
      {
        file: "pvc.yaml",
        template: (importstr "templates/pvc.yaml.j2"),
        name: "concourse",
        type: "persistentvolumeclaim"
      },
    ],

    deploy: [
        { name: "postgres/postgres",
          variables: {
            password: "concourse",
            user: "concourse",
            dbname: "concourse",
            image: "postgres:9.5.5"

          }
        },
        { name: "$self"},
    ]


  }, params)
