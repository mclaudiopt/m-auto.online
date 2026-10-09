#!/bin/bash
cd "/d/Tutorials/m-auto.online" || exit 1
git add index.html
git commit -m "SEO: meta tags, OpenGraph, JSON-LD melhorados com keywords em PT"
git push origin main
echo "DEPLOY FEITO"
