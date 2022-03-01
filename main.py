from dataclasses import field
from email import message
from tokenize import Double
from urllib import request
from flask import Flask
from flask_restful import Api,Resource, abort,reqparse,fields,marshal_with,request
from flask_sqlalchemy import SQLAlchemy
from matplotlib.font_manager import json_load
from sqlalchemy import Float, true
import json

app = Flask(__name__)
api = Api(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
db = SQLAlchemy(app)

class gorevModel(db.Model):
    userID = db.Column(db.String(200),nullable = False)
    gorevNO = db.Column(db.Integer,primary_key = True,autoincrement=True)
    enlem=db.Column(db.String(20),nullable=False)
    boylam=db.Column(db.String(20),nullable=False)
    def __repr__(self):
        return f""

#db.create_all()   
gorev_put_args = reqparse.RequestParser()
gorev_put_args.add_argument('userID',type=str,help="Kullanici ID")
gorev_put_args.add_argument('enlem',type=str,help="Gorev Enlem")
gorev_put_args.add_argument('boylam',type=str,help="Gorev Boylam")

resource_field={
    'userID':fields.String,
    'gorevNO':fields.Integer,
    'enlem':fields.String,
    'boylam':fields.String
}

class Gorev(Resource):
    @marshal_with(resource_field)
    def get(self,userID):
        if(userID=="0"):
            result = gorevModel.query.all()
            return result
        result = gorevModel.query.filter_by(userID=userID).all()
        if not result:
            abort(404,message="Bu ID ile kayitli bir gorev bulunamadi...")
        else:
            return result
    @marshal_with(resource_field)
    def post(self,userID):
        request_data= request.data
        request_data = json.loads(request_data.decode('utf-8'))
        grv = gorevModel(userID=request_data['userID'],enlem=request_data['enlem'],boylam=request_data['boylam'])
        try:
            db.session.add(grv)
            db.session.commit()
            return 201
        except:
            print("Hata...")
            return 666
    @marshal_with(resource_field)
    def delete(self,userID):
        result = gorevModel.query.filter_by(userID=userID).all()
        if not result:
            abort(404,message="Bu kullaniciya ait gorev bulunamadi...")
        else:
            for s in result:
                db.session.delete(s)
            db.session.commit()
            return 'silindi',31
    

api.add_resource(Gorev,"/gorev/<string:userID>")

if __name__ == "__main__":
    app.run(debug=True)