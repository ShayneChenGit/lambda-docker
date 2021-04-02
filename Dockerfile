FROM public.ecr.aws/lambda/nodejs:12

COPY app.js package.json /var/task/

RUN npm install

CMD ["app.handler"]
