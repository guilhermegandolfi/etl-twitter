import requests
import json
import os
import boto3
import shutil
from datetime import datetime


class Ingestion:
    def __init__(self, url=None, path=None, nam_dir='/tmp'):
        self.url = url
        self.path = path
        self.nam_dir = nam_dir

    def get_data(self):
        try:
            url_data = f"{self.url}/{self.path}/?format=json"
            while True:
                print(url_data)
                result = requests.get(url_data)
                if result.status_code == 200:
                    result_data = result.json()

                    nam_path = f'{self.nam_dir}/{self.path}/'
                    nam_file = f'{self.path}'

                    if not os.path.exists(nam_path):
                        os.makedirs(nam_path)
                    dt_now = datetime.now().strftime('%d_%m_%Y_%H%M%S')
                    with open(f'{nam_path}/{nam_file}_{dt_now}.json', "w") as file:
                        json.dump(result.json(), file, indent=4)

                    url_data = result_data.get('next')
                    if url_data is None:
                        break
        except requests.exceptions.HTTPError as e:
            return f"Erro de requisição: {e}"

    def upload_s3(self, bucket_name, prefix=None):
        s3 = boto3.client('s3', region_name='us-east-1')

        for rootdir, dirs, files in os.walk(self.nam_dir):
            for i in files:
                path = f'{rootdir}/{i}'
                prefix_s3 = rootdir.split('/')[-1]
                dt_now = datetime.now().strftime('dat_load=%Y_%m_%d')
                prefix_s3 = f'{prefix_s3}/{dt_now}/{i}'
                if prefix is None:
                    s3.upload_file(path, bucket_name, prefix_s3)
                else:
                    s3.upload_file(path, bucket_name, f'{prefix}/{prefix_s3}')

    def clean_tmp(self):
        nam_path = f'{self.nam_dir}'
        if os.path.exists(nam_path):
            shutil.rmtree(nam_path)

    def main(self):
        url = 'https://swapi.dev/api'
        path = ['films', 'planets', 'species',
                'starships', 'vehicles', 'people']
        for i in path:
            star_wars = Ingestion(url, i)
            star_wars.get_data()

        star_wars_upload = Ingestion()
        star_wars_upload.upload_s3(
            bucket_name='star-wars-etl-dev', prefix='raw_data')


def lambda_handler(event, context):
    ingestion = Ingestion()
    ingestion.main()
    return {
        'statusCode': 200
    }


if __name__ == "__main__":
    ingestion = Ingestion()
    ingestion.main()
