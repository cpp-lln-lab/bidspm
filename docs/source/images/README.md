# Making figures for the doc

Making DAGs (directed acyclic graphs) with makefile and
[makefile2graph](https://github.com/lindenb/makefile2graph).

```
make -Bnd | make2graph | dot -Tpng -o out.png
```
