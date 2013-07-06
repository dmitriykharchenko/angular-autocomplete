angular.module('application.directives').directive "ng-autocomplete", (keycodes, $compile) ->

  restrict: "A"
  scope: 
    model: "=ngAutocompleteModel"
    source: "&ngAutocompleteSource"

  controller: ($scope) ->
    $scope.min_term_length = 3;
    $scope.max_items_count = 15;

    $scope.fetch = (term) ->
      $scope.source(term).success (data) ->
        $scope.list = []
        _.each data, (item, index) ->
          return false if $scope.max_items_count <= index
          $scope.list.push item
          $scope.data[item.name] = item;

  link: ($scope, $element, $attrs) ->
    elem = $($element)

    $compile($ "<div ng-autocomplete-list></div>") $scope, (list_layout) ->
      elem.after list_layout

    $scope.pointer = null;
    $scope.list = []
    $scope.data = {}

    $scope.$watch "model.name", (value) ->
      if value
        elem.val value

    $scope.$watch "pointer", (pointer) ->
      if pointer isnt null and pointer isnt undefined and $scope.list[$scope.pointer]
        elem.val $scope.list[$scope.pointer].name
      else if $scope.model && $scope.model.name
        elem.val $scope.model.name
      else if $scope.term
        elem.val $scope.term

    $scope.$watch "term", (term) ->
      if term
        $scope.fetch term

    elem.on "keydown", () ->
      switch keycodes event.keyCode
        when 'UP' then $scope.$apply () ->
          if $scope.pointer isnt null
            $scope.pointer -= 1

        when 'DOWN' then $scope.$apply () ->
          if $scope.list.length is 0
            $scope.term = elem.val();

          else if $scope.pointer is null
            $scope.pointer = 0
          else
            $scope.pointer = ($scope.pointer + 1) % $scope.list.length;

        when 'ENTER', 'NUMPAD_ENTER' then $scope.$apply () ->
          $scope.model.update $scope.list[$scope.pointer]
          $scope.term = null;

        when 'ESCAPE' then $scope.$apply () ->
          $scope.list = [];
          $scope.pointer = null;

      if $scope.pointer < 0
        $scope.pointer = null

    elem.on "keyup", () ->
      keycode = keycodes(event.keyCode)
      term = elem.val()
      if keycode is "TYPE" or keycode is "BACKSPACE" and term
        $scope.$apply () ->
          $scope.term = term
          $scope.model.update($scope.data[$scope.term] || null)
