import logging
import gspread
import json
import os

from flask import Flask, jsonify
from werkzeug.exceptions import HTTPException, NotFound
import google.auth

app = Flask(__name__)

logging.getLogger().setLevel(logging.INFO)

service_account_path = 'app/credentials/client-secret.json'


@app.route('/id/<id>', methods=['GET'])
def api_get_by_id(id):
    logging.info('Getting the data by id : {}'.format(id))
    record = get_record(id=id)
    return json.dumps(record)


@app.route('/spreadsheet/<spreadsheet_id>/id/<id>', methods=['GET'])
def api_get_by_spreadsheet(spreadsheet_id, id):
    logging.info('Getting the data by spreadsheet : {}'.format(spreadsheet_id))
    record = get_record(spreadsheet_id=spreadsheet_id, id=id)
    return json.dumps(record)


@app.route('/spreadsheet/<spreadsheet_id>/worksheet/<worksheet_id>/id/<id>', methods=['GET'])
@app.route('/project/<spreadsheet_id>/env/<worksheet_id>/key/<id>', methods=['GET'])
def api_get_by_worksheet(spreadsheet_id, worksheet_id, id):
    logging.info('Getting the by data spreadsheet : {} and worksheet: {}'.format(spreadsheet_id, worksheet_id))
    record = get_record(spreadsheet_id=spreadsheet_id, worksheet_id=worksheet_id, id=id)
    return json.dumps(record)


def get_client():
    if os.path.exists(service_account_path):
        return gspread.service_account(service_account_path)
    else:
        credentials, project = google.auth.default(
            scopes=[
                'https://www.googleapis.com/auth/spreadsheets',
                'https://www.googleapis.com/auth/drive'
                ])
        return gspread.authorize(credentials)


def get_record(**kwargs):
    client = get_client()
    spreadsheet_id = kwargs.get('spreadsheet_id') or os.environ.get('SPREADSHEET_ID', '1fRUorOlOFRQ7-tNs-OzPDHF9HKDWWi9zmo4oMd1AGVU')
    worksheet_id = kwargs.get('worksheet_id') or os.environ.get('WORKSHEET_ID', 'Sheet1')

    try:
        sheet = client.open(spreadsheet_id).worksheet(worksheet_id)
    except Exception as e:
        logging.info('Could not open spreadsheet by name.. trying by spreadsheet id')
        try:
            sheet = client.open_by_key(spreadsheet_id).worksheet(worksheet_id)
        except Exception as e:
            logging.info('Could not open by worksheet id .. trying first worksheet')
            try:
                sheet = client.open(spreadsheet_id).get_worksheet(0)
            except Exception as e:
                logging.info('Could not open by worksheet id .. trying first worksheet')
                sheet = client.open_by_key(spreadsheet_id).get_worksheet(0)

    data = sheet.get_all_records()

    for d in data:
        if d.get('key') and d['key'] == kwargs['id']:
            return d
        if d.get('id') and d['id'] == int(kwargs['id']):
            return d

    return data


@app.errorhandler(Exception)
def handle_exception(error):
    success = False
    if isinstance(error, NotFound):
        status_code = 404
        message = 'NOT FOUND'
    else:
        status_code = error.args[0].get('code')
        message = error.args[0].get('message')

    response = {
        'success': success,
        'error': {
            'message': message
        }
    }
    return jsonify(response), status_code


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
