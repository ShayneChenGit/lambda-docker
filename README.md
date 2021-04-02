# 创建定义为容器映像的函数
使用 Docker CLI 创建容器映像，然后使用 Lambda 控制台从容器映像创建函数。

## 前提
* linux 机器
* 安装有 aws cli
* 安装有 docker
* 安装有 nodejs

## 一、创建容器映像
### 1. 创建项目目录，在其中创建 app.js 文件
```
mkdir lambda-docker
cd lambda-docker/
vim app.js
```
app.js
```
exports.handler = async (event) => {
    // TODO implement
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };
    return response;
};                 
```
### 2. 在项目目录创建 DockerFIle
```
FROM public.ecr.aws/lambda/nodejs:12

# Copy function code and package.json
COPY app.js package.json /var/task/

# Install NPM dependencies for function
RUN npm install

# Set the CMD to your handler
CMD [ "app.handler" ]
```
### 3.创建 package.json 文件，文件为空
```
vim package.json
```
### 4. 运行命令，一路回车接受所有默认值
```
npm init
```
### 5. 生成 Docker 映像
```
docker build -t hello-world .
```

### 6. 本地测试 image
* 运行 docker image
```
docker run -p 9000:8080 hello-world:latest
```
* 测试 lambda 函数。在新的terminal，运行以下命令
```
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```

## 二、将 docker image 上传到 Amazon ECR
### 1. 身份验证
```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 875593617141.dkr.ecr.us-east-1.amazonaws.com
```

### 2. 在 Amazon ECR 中创建存储库
```
aws ecr create-repository --repository-name hello-world --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
```

### 3. 将 image 标记为与 repository 名称匹配
```
docker tag hello-world:latest 875593617141.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
```
### 4. 上传image
```
docker push 875593617141.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
```

## 三、更新role的权限
确保创建函数的 role 有如下 policy：
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:SetRepositoryPolicy",
                "ecr:GetRepositoryPolicy"
            ],
            "Resource": "arn:aws:ecr:us-east-1:875593617141:repository/hello-world"
        }
    ]
} 
```

## 四、创建定义为 container image 的 Lambda 函数
### 1. 在 Lambda 控制台， 点击 Create Function
### 2. 选择 Container image
### 3. 在 Basic information，执行以下操作：
* 函数名称： DockerLambdaForShayne
* container image URI： 875593617141.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
### 4. 创建函数

## 五、调用Lambda函数
在 Test 选项下，点击 Invoke。

可以看到执行结果。