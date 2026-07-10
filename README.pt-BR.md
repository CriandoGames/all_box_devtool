<p align="center">
  <img src="doc/banner.svg" alt="all_box_devtool" width="720">
</p>

<p align="center">
  <img src="doc/screenshot_overview.png" alt="Painel do all_box_devtool ao lado do app inspecionado, editando um valor de lista" width="900">
</p>

<h1 align="center">all_box_devtool</h1>

<p align="center">
🇺🇸 <a href="https://github.com/CriandoGames/all_box_devtool/blob/main/README.md">English</a> | 🇧🇷 Português
</p>

<p align="center">
  <a href="https://github.com/CriandoGames/all_box_devtool/blob/main/LICENSE"><img src="https://img.shields.io/github/license/CriandoGames/all_box_devtool" alt="license"></a>
  <img src="https://img.shields.io/badge/Flutter-DevTools%20extension-0175C2?logo=flutter&logoColor=white" alt="Flutter DevTools extension">
  <img src="https://img.shields.io/badge/status-1.0.0%20%E2%80%94%20primeiro%20lan%C3%A7amento-brightgreen" alt="1.0.0 — primeiro lançamento">
</p>

<p align="center">
💡 Uma <a href="https://docs.flutter.dev/tools/devtools/extensions">extensão do DevTools</a> para o <a href="https://pub.dev/packages/all_box"><code>all_box</code></a>: navegue e edite containers <code>AllBox</code> direto do Flutter/Dart DevTools.
</p>

## Sumário

- [Funcionalidades](#-funcionalidades)
- [Requisitos](#-requisitos)
- [Passo a passo](#-passo-a-passo)
- [Uso](#-uso)
- [Como funciona](#️-como-funciona)
- [Informações adicionais](#-informações-adicionais)

## 🚀 Funcionalidades

- 🔍 **Lista de containers.** Todo container `AllBox` vivo no app
  inspecionado, filtrável por nome, com badges de backend/flush pendente.
- 📄 **Detalhe do container.** As chaves e valores do container
  selecionado, filtráveis por nome de chave, além de um resumo de
  armazenamento (backend, quantidade de chaves, tamanho aproximado).
- ✏️ **Edição in loco.** Toque em uma chave para visualizá-la, editá-la
  como JSON bruto, ou excluí-la — as escritas vão direto para o app em
  execução através do VM Service.
- 🔁 **Atualização por polling.** O painel se atualiza automaticamente a
  cada 2 segundos, além de um botão de atualização manual. O `all_box`
  0.6.0 já posta eventos de mutação (debug-only) no VM Service em
  write/remove/erase, mas esta extensão ainda não os consome (veja
  [Como funciona](#️-como-funciona)) — por enquanto a atualização
  continua baseada em pull.
- 🧯 **Somente debug/profile.** A introspecção do `all_box`
  (`AllBoxInspector`) é um no-op em builds de release — nada aqui
  adiciona overhead em tempo de execução a um app publicado, e não há
  nada para ver em uma sessão de DevTools de um build de release, por
  design.

## 📋 Requisitos

O app que você está depurando precisa depender de:

```yaml
dependencies:
  all_box: ^0.6.0
```

Foi o `all_box` 0.6.0 que introduziu o `AllBoxInspector` — a superfície
de introspecção somente-leitura e debug-only que esta extensão lê através
do VM Service. Nada mais é exigido do lado do app inspecionado.

## 📦 Passo a passo

1. No app que usa `all_box`, garanta que o `pubspec.yaml` tenha o
   `all_box` em `dependencies` e o `all_box_devtool` em
   `dev_dependencies`:

   ```yaml
   dependencies:
     all_box: ^0.6.0

   dev_dependencies:
     all_box_devtool: ^1.0.0
   ```

2. Rode:

   ```sh
   flutter pub get
   ```

3. Execute o app em modo `debug` ou `profile`:

   ```sh
   flutter run
   ```

4. Abra o Flutter/Dart DevTools pelo IDE ou pelo link exibido no
   terminal.
5. Na primeira abertura, habilite a extensão `all_box_devtool` quando o
   DevTools solicitar permissão.
6. Abra a aba "all_box_devtool".
7. Selecione um container para ver suas chaves, editar valores como JSON
   bruto ou remover entradas.

Mais detalhes sobre a permissão de extensões estão na documentação oficial:
[Use a DevTools extension](https://docs.flutter.dev/tools/devtools/extensions#use-a-devtools-extension).

## 🧪 Uso

Uma vez habilitada, uma nova aba "all_box_devtool" aparece no DevTools
enquanto seu app está em execução.

- Selecione um container à esquerda para inspecionar suas chaves à
  direita.
- Digite em qualquer um dos campos de busca para filtrar containers ou
  chaves.
- Toque em qualquer chave para visualizar, editar (como JSON bruto) ou
  excluir.
- Use o botão de atualização, ou apenas aguarde — o painel faz polling a
  cada 2 segundos automaticamente.

<p align="center">
  <img src="doc/screenshot_containers_list.png" alt="Lista de containers e painel de detalhe do container" width="800">
</p>

<p align="center">
  <img src="doc/screenshot_key_editor.png" alt="Diálogo de edição de chave, editando um valor como JSON bruto" width="800">
</p>

## 🛠️ Como funciona

- A extensão conversa com o app inspecionado apenas através do VM
  Service — ela avalia `AllBoxInspector.snapshotAsJson()` (e, para
  escritas, `AllBox(container).write(...)`/`.remove(...)`) na isolate
  principal do app. Nenhum pacote é adicionado ao grafo de dependências
  do app inspecionado além do próprio `all_box`.
- O `all_box` não tem reatividade embutida por design (veja seu próprio
  [README](https://github.com/CriandoGames/all_box#-precisa-de-reatividade)),
  então esta extensão é baseada em pull: um `PollingController` atualiza
  a cada 2 segundos, e toda escrita/exclusão dispara uma atualização
  extra imediata para que a UI reflita suas próprias edições na hora.
- Racional completo de design, responsabilidades pasta a pasta, e o
  motivo de cada decisão: [ARCHITECTURE.md](./ARCHITECTURE.md).

## 📚 Informações adicionais

- Notas de arquitetura e design: [ARCHITECTURE.md](./ARCHITECTURE.md).
- `all_box`: <https://github.com/CriandoGames/all_box>.
- Issues: <https://github.com/CriandoGames/all_box_devtool/issues>.

---

Issues e pull requests são bem-vindos no
[repositório do GitHub](https://github.com/CriandoGames/all_box_devtool).
