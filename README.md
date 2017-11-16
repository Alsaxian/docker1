-------------------
# Rapport du TP Utilisation de Docker

Binôme : Swarth-Elia ___ et Xian YANG   
Promotion : Data Science Math   
L'adresse IP de la machine virtuelle : [http://192.168.76.13/](http://192.168.76.13/)   
Date : 16 nov. 2017   

[TOC]

## 0. Préparation d'une machine virtuelle avec Docker
En premier temps, on monte une VM avec docker pré-installé sur Openstack. 
Après passer en root afin de faciliter la saisie de commandes, 
on vérifie l’installation de docker sur la VM avec
```sh
# docker version
```
ce qui vous renvoie le numéro de sa version et assure son bon fonctionnement.
  
  
## I. Installation d'un docker nginx

- [ ] 支持以 PDF 格式导出文稿
- [x] 改进 Cmd 渲染算法，使用局部渲染技术提高渲染效率
- [x] 新增 Todo 列表功能
- [x] 修复 LaTex 公式渲染问题
- [x] 新增 LaTex 公式编号功能

On va d’abord trouver la bonne version de docker nginx qu’on va utiliser par la suite. 
Pour le faire, on peut taper
```sh
# docker search --stars=3 --no-trunc nginx
```
qui va chercher par défaut sur dockerhub et puis afficher toutes les docker images disponibles 
portant le nom ```nginx```, ayant au moins 3 étoiles accompagnées d’une description non-tronquée. 
On voit bien en tête de cette liste l’image officielle avec 7219 étoiles au moment de la rédaction de ce rapport.

### 2. 书写一个质能守恒公式[^LaTeX]
![](http://latex.codecogs.com/gif.latex?\\frac{1}{1+sin(x)})
$$E=mc^2$$
```bash
$ docker images -a
$ cd 
```
### 3. 高亮一段代码[^code]

```python
@requires_authorization
class SomeClass:
    pass

if __name__ == '__main__':
    # A comment
    print 'hello world'
```

### 4. 高效绘制 [流程图](https://www.zybuluo.com/mdeditor?url=https://www.zybuluo.com/static/editor/md-help.markdown#7-流程图)

```flow
st=>start: Start
op=>operation: Your Operation
cond=>condition: Yes or No?
e=>end

st->op->cond
cond(yes)->e
cond(no)->op
```

### 5. 高效绘制 [序列图](https://www.zybuluo.com/mdeditor?url=https://www.zybuluo.com/static/editor/md-help.markdown#8-序列图)

```seq
Alice->Bob: Hello Bob, how are you?
Note right of Bob: Bob thinks
Bob-->Alice: I am good thanks!
```

### 6. 高效绘制 [甘特图](https://www.zybuluo.com/mdeditor?url=https://www.zybuluo.com/static/editor/md-help.markdown#9-甘特图)

```gantt
    title 项目开发流程
    section 项目确定
        需求分析       :a1, 2016-06-22, 3d
        可行性报告     :after a1, 5d
        概念验证       : 5d
    section 项目实施
        概要设计      :2016-07-05  , 5d
        详细设计      :2016-07-08, 10d
        编码          :2016-07-15, 10d
        测试          :2016-07-22, 5d
    section 发布验收
        发布: 2d
        验收: 3d
```

### 7. 绘制表格

| 项目        | 价格   |  数量  |
| --------   | -----:  | :----:  |
| 计算机     | \$1600 |   5     |
| 手机        |   \$12   |   12   |
| 管线        |    \$1    |  234  |