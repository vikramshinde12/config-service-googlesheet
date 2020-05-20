FROM python:3.7

MAINTAINER Vikram Shinde "vik.shinde@gmail.com"

COPY requirements.txt /requirements.txt

WORKDIR /

RUN pip3 install -r requirements.txt

COPY . /

ENTRYPOINT [ "python3" ]

CMD [ "app/app.py" ]
