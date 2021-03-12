# Vansible with Kubespray

## 소개

Vagrant, Ansible, Kubespray(Docker+Kubernetes)를 사용하여<br/>
손쉽고 빠르게 개발, 학습, 강의 환경 구축을 목적으로 만들어진 IaC(Infra as Code) 도구<br/>

## 사용 전 필요 조건

사용자의 환경에 [Vagrant](https://www.vagrantup.com/downloads)와 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)가 미리 설치되있어야 함

## 사용 방법

<span>1.</span> [.env](.env) 파일 구성

<span>2.</span> kubespray를 수동으로 구성하고 싶다면, [CLUSTER_STRUCTURE_AUTO_CREATE=no](.env#L33)으로 옵션을 설정하고,
**cluster folder** 를 목적에 맞게 구성한다

<span>3.</span> Vagrantfile이 위치한 경로에서 하단의 명령어를 bash 쉘에 입력한다

```sh
$ vagrant plugin install vagrant-env vagrant-vbguest
$ vagrant up
$ vagrant ssh $(vagrant status | tail -5 | sed -n '1p' | awk '{ print $1}')
```

<hr/>

## Introduce

Using Vagrant, Ansible, Kubespray (Docker + Kubernetes)<br/>
IaC (Infra as Code) tool designed for easy and fast development, learning, and lecture environment construction

## Requirements before use

Vagrant and VirtualBox must be installed in the user's environment in advance

## How to Use

<span>1.</span> Configure the [.env](.env) file

<span>2.</span> If you want to configure kubespray with manually, set [CLUSTER_STRUCTURE_AUTO_CREATE=no](.env#L33)
then configure the **cluster folder**

<span>3.</span> Type the following command into the bash shell in the path where the Vagrantfile is located.

```sh
$ vagrant plugin install vagrant-env vagrant-vbguest
$ vagrant up
$ vagrant ssh $(vagrant status | tail -5 | sed -n '1p' | awk '{ print $1}')
```

<hr/>

## 개인 문서, Private Documents

### [https://github.com/dfnk5516/vansible_with_kubespray/wiki](https://github.com/dfnk5516/vansible_with_kubespray/wiki)

<hr/>

## 공식 문서, Official Documents

### [Vagrant](https://www.vagrantup.com/docs)

### [Ansible](https://docs.ansible.com/)

### [Docker](https://docs.docker.com/)

### [Kubernetes](https://kubernetes.io/ko/docs/home/)

<hr/>

## 참고한 곳, Site referenced

### ruby<br/>

[Ruby 처음 배우기:데이터타입,조묵헌](https://smartbase.tistory.com/47)<br/>
[Joinc,yundream](https://www.joinc.co.kr/w/Site/Ruby/File)<br/>

### vagrant<br/>

[노력 이기는 재능 없고 노력 외면하는 결과도 없다,asdf](https://m.blog.naver.com/PostView.nhn?blogId=sory1008&logNo=220759961657&proxyReferer=https:%2F%2Fwww.google.com%2F)<br/>
[YOUNG.K](https://rangken.github.io/blog/2015/vagrant-1/)

### ansible<br/>

[세모데](https://semode.tistory.com/m/164)<br/>
[Sentimental Programmer](https://yoonbh2714.blogspot.com/2020/09/ansible-ssh-password.html)<br/>
[부들잎의 이것저것](https://forteleaf.tistory.com/entry/ansible-%EC%9E%90%EB%8F%99%ED%99%94%EC%9D%98-%EC%8B%9C%EC%9E%91)<br/>

### python j2 template<br/>

[Python2.net](https://www.python2.net/questions-962144.htm)<br/>

### kubespray<br/>

[브랜든의 블로그](https://brenden.tistory.com/109)<br/>
[alice_k106님의 블로그](https://m.blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221315933945&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F)<br/>
[teamsmiley 블로그](https://teamsmiley.github.io/2020/09/30/kubespray-01-vagrant/)<br/>

### lecture<br/>

[다양한 환경을 앤서블(Ansible)로 관리하기 with 베이그런트(Vagrant),조훈](https://www.inflearn.com/course/ansible-%EC%9D%91%EC%9A%A9/dashboard)<br/>

### git repository<br/>

[kairen/kubeadm-ansible](https://github.com/kairen/kubeadm-ansible)<br/>
[kubernetes-sigs/kubespray](https://github.com/kubernetes-sigs/kubespray)
