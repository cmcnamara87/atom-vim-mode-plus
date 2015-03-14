{View, TextEditorView} = require 'atom'

module.exports =
class VimCommandModeInputView extends View
  @content: ->
    @div class: 'command-mode-input', =>
      @div class: 'editor-container', outlet: 'editorContainer'

  initialize: (@viewModel, opts = {})->
    if opts.class?
      @editorContainer.addClass opts.class

    if opts.hidden
      # TODO: this no longer works with atom-text-editor
      @editorContainer.addClass 'hidden-input'

    @editorElement = document.createElement "atom-text-editor"
    @editorElement.classList.add('editor')
    @editorElement.getModel().setMini(true)
    @editorContainer.append(@editorElement)

    @singleChar = opts.singleChar
    @defaultText = opts.defaultText ? ''

    @panel = atom.workspace.addBottomPanel(item: this, priority: 100)

    @focus()
    @handleEvents()

  handleEvents: ->
    if @singleChar?
      atom.commands.add(@editorElement, 'textInput', @autoSubmit)
    else
      atom.commands.add(@editorElement, 'editor:newline', @confirm)
    atom.commands.add(@editorElement, 'core:confirm', @confirm)
    atom.commands.add(@editorElement, 'core:cancel', @cancel)
    atom.commands.add(@editorElement, 'blur', @cancel)

  autoSubmit: (event) =>
    @editorElement.getModel().setText(event.data)
    @confirm()

  confirm: =>
    @value = @editorElement.getModel().getText() or @defaultText
    @viewModel.confirm(@)
    @remove()

  focus: =>
    @editorElement.focus()

  cancel: (e) =>
    @viewModel.cancel(@)
    @remove()

  remove: =>
    atom.workspace.getActivePane().activate()
    @panel.destroy()
