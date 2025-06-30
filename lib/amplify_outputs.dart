const amplifyConfig = r'''{
  "auth": {
    "user_pool_id": "eu-west-2_QSnlKBolR",
    "aws_region": "eu-west-2",
    "user_pool_client_id": "1ku0perdik2o3qrmbrl2obac54",
    "identity_pool_id": "eu-west-2:45019f2e-6a2d-4900-bee3-c9140d4d533a",
    "mfa_methods": [],
    "standard_required_attributes": [
      "email",
      "address"
    ],
    "username_attributes": [
      "email"
    ],
    "user_verification_types": [
      "email"
    ],
    "groups": [],
    "mfa_configuration": "NONE",
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_numbers": true,
      "require_symbols": true,
      "require_uppercase": true
    },
    "unauthenticated_identities_enabled": true
  },
  "data": {
    "url": "https://uxbilkbyivajjpqag3s6vnnxxi.appsync-api.eu-west-2.amazonaws.com/graphql",
    "aws_region": "eu-west-2",
    "default_authorization_type": "AMAZON_COGNITO_USER_POOLS",
    "authorization_types": [
      "AWS_IAM"
    ],
    "model_introspection": {
      "version": 1,
      "models": {
        "Todo": {
          "name": "Todo",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "content": {
              "name": "content",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "isDone": {
              "name": "isDone",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Todos",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "provider": "userPools",
                    "ownerField": "owner",
                    "allow": "owner",
                    "identityClaim": "cognito:username",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        }
      },
      "enums": {},
      "nonModels": {}
    }
  },
  "version": "1.4"
}''';