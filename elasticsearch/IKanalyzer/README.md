# Elastic Analyzer

## ElasticSearch IK analyzer

簡單的 IK analyzer plugin 使用方法, [IK analyzer github](https://github.com/medcl/elasticsearch-analysis-ik).

在 container 中使用`elasticsearch-plugin install`會有問題，猜是因為IK會需要字典檔案的關係

使用 dockerfile
```dockerfile
FROM elasticsearch:7.16.3

# plugin version need equal to ES
RUN mkdir -p /usr/share/elasticsearch/plugins/ik && \
    curl -sSL https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.16.3/elasticsearch-analysis-ik-7.16.3.zip \
    -o /tmp/tmp.zip && \
    unzip /tmp/tmp.zip \
    -d /usr/share/elasticsearch/plugins/ik && \
    rm /tmp/tmp.zip

```

1. build `docker build -t my_es .`
2. run `docker run -d --rm -e discovery.type=single-node -p 9200:9200 my_es`
3. create index template
  ```shell
  curl -XPUT http://localhost:9200/_index_template/ik_example2 \
  -H 'Content-Type:application/json' -d'
  {
    "version": 2,
    "priority": 2,
    "index_patterns": ["example*"],
    "template": {
      "settings": {
        "analysis": {
          "analyzer": {
            "default": {
              "tokenizer": "ik_max_word"
            }
          }
        }
      }
    }
  }'
  ```
  - legecy template
    ```shell
    curl -XPUT http://localhost:9200/_template/ik_example2 \
    -H 'Content-Type:application/json' -d'
    {
      "version": 2,
      "priority": 2,
      "index_patterns": ["example*"],
      "settings": {
        "analysis": {
          "analyzer": {
            "default": {
              "tokenizer": "ik_max_word"
            }
          }
        }
      }
    }'
    ```
4. create index
  ```shell
  curl -XPUT http://localhost:9200/example123
  ```
5. get index info
  ```shell
  curl -XGET http://localhost:9200/example123
  ```
6. verify analyzer
  ```shell
  curl -XGET http://localhost:9200/example123/_analyze \
  -H 'Content-Type:application/json' -d'
  {
     "text":"欲穷千里目，更上一层楼。"
  }'
  ```

::: spoiler response

```json
GET example123/_analyze
{
  "text":"欲穷千里目，更上一层楼。"
}

{
  "tokens": [
    {
      "token": "欲穷千里目",
      "start_offset": 0,
      "end_offset": 5,
      "type": "CN_WORD",
      "position": 0
    },
    {
      "token": "欲穷千里",
      "start_offset": 0,
      "end_offset": 4,
      "type": "CN_WORD",
      "position": 1
    },
    {
      "token": "千里目",
      "start_offset": 2,
      "end_offset": 5,
      "type": "CN_WORD",
      "position": 2
    },
    {
      "token": "千里",
      "start_offset": 2,
      "end_offset": 4,
      "type": "CN_WORD",
      "position": 3
    },
    {
      "token": "千",
      "start_offset": 2,
      "end_offset": 3,
      "type": "TYPE_CNUM",
      "position": 4
    },
    {
      "token": "里",
      "start_offset": 3,
      "end_offset": 4,
      "type": "COUNT",
      "position": 5
    },
    {
      "token": "目",
      "start_offset": 4,
      "end_offset": 5,
      "type": "CN_CHAR",
      "position": 6
    },
    {
      "token": "更上一层楼",
      "start_offset": 6,
      "end_offset": 11,
      "type": "CN_WORD",
      "position": 7
    },
    {
      "token": "更上一层",
      "start_offset": 6,
      "end_offset": 10,
      "type": "CN_WORD",
      "position": 8
    },
    {
      "token": "一层楼",
      "start_offset": 8,
      "end_offset": 11,
      "type": "CN_WORD",
      "position": 9
    },
    {
      "token": "一层",
      "start_offset": 8,
      "end_offset": 10,
      "type": "CN_WORD",
      "position": 10
    },
    {
      "token": "一",
      "start_offset": 8,
      "end_offset": 9,
      "type": "TYPE_CNUM",
      "position": 11
    },
    {
      "token": "层楼",
      "start_offset": 9,
      "end_offset": 11,
      "type": "CN_WORD",
      "position": 12
    },
    {
      "token": "层",
      "start_offset": 9,
      "end_offset": 10,
      "type": "COUNT",
      "position": 13
    },
    {
      "token": "楼",
      "start_offset": 10,
      "end_offset": 11,
      "type": "CN_CHAR",
      "position": 14
    }
  ]
}
```
:::

### icu Analyzer

```json
PUT lkey_geometry_a
{
  "settings": {
    "index": {
      "analysis": {
        "analyzer": {
          "nfkc_cf_normalized": {
            "tokenizer": "icu_tokenizer",
            "char_filter": [
              "icu_normalizer"
            ]
          },
          "nfd_normalized": {
            "tokenizer": "icu_tokenizer",
            "char_filter": [
              "nfd_normalizer"
            ]
          }
        },
        "char_filter": {
          "nfd_normalizer": {
            "type": "icu_normalizer",
            "name": "nfc",
            "mode": "decompose"
          }
        }
      }
    }
  },
  "mappings" : {
    "dynamic_templates":[
      {
        "strings_as_keyword": {
          "match_mapping_type": "string",
          "mapping": {
              "type": "keyword"
          }
        }
      }
    ],
    "properties" : {
      "coordinates": {
        "type": "geo_shape"
      },
      "center": {
        "type": "geo_point"
      }
    }
  }
}

```

##  ICU Analyzer

https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-icu.html

```json
PUT icu_sample
{
  "settings": {
    "index": {
      "analysis": {
        "analyzer": {
          "nfkc_cf_normalized": {
            "tokenizer": "icu_tokenizer",
            "char_filter": [
              "icu_normalizer"
            ]
          },
          "nfd_normalized": {
            "tokenizer": "icu_tokenizer",
            "char_filter": [
              "nfd_normalizer"
            ]
          }
        },
        "char_filter": {
          "nfd_normalizer": {
            "type": "icu_normalizer",
            "name": "nfc",
            "mode": "decompose"
          }
        }
      }
    }
  }
}
```

Test analyzer from a exit index
```json
GET icu_sample/_analyze
{
  "analyzer": "nfkc_cf_normalized",
  "text" : ["台北市北投區泉源路３９之２７號地下一層", "ｼｰｻｲﾄﾞﾗｲﾅｰ"]
}


GET /_analyze
{
  "tokenizer" : "icu_tokenizer",
  "char_filter": ["icu_normalizer"],
  "text" : "台北市北投區泉源路３９之２７號地下一層"
}
```
