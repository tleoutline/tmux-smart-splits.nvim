#!/usr/bin/env bash
# vim: ft=sh

get_option() {
  local option value default
  option="$1"
  default="$2"
  value="$([[ -n $(tmux show-options -gq "$option") ]] \
      && tmux show-option -gqv "$option" \
      || echo "$default")"

  # Deprecated, for backward compatibility
  if [[ $value == 'null' ]]; then
      echo ""
      return
  fi

  echo "$value"
}

no_wrap=$(get_option '@smart-splits_no_wrap' '')

move_left_key=$(get_option  '@smart-splits_move_left_key'  'C-h')
move_down_key=$(get_option  '@smart-splits_move_down_key'  'C-j')
move_up_key=$(get_option    '@smart-splits_move_up_key'    'C-k')
move_right_key=$(get_option '@smart-splits_move_right_key' 'C-l')

resize_left_key=$(get_option  '@smart-splits_resize_left_key'  'M-h')
resize_down_key=$(get_option  '@smart-splits_resize_down_key'  'M-j')
resize_up_key=$(get_option    '@smart-splits_resize_up_key'    'M-k')
resize_right_key=$(get_option '@smart-splits_resize_right_key' 'M-l')

resize_step_size=$(get_option '@smart-splits_resize_step_size' '5')

# Setup all the navigation key-mappings.
setup_navigation() {
  if [ -z $no_wrap ]; then
    for k in $(echo "$move_left_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "select-pane -L"; done
    for k in $(echo "$move_down_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "select-pane -D"; done
    for k in $(echo "$move_up_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "select-pane -U"; done
    for k in $(echo "$move_right_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "select-pane -R"; done
    # tmux bind-key -T copy-mode-vi "$move_left_key"  select-pane -L
    # tmux bind-key -T copy-mode-vi "$move_down_key"  select-pane -D
    # tmux bind-key -T copy-mode-vi "$move_up_key"    select-pane -U
    # tmux bind-key -T copy-mode-vi "$move_right_key" select-pane -R
  else
    for k in $(echo "$move_left_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "if -F '#{pane_at_left}'   '' 'select-pane -L'"; done
    for k in $(echo "$move_down_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "if -F '#{pane_at_bottom}' '' 'select-pane -D'"; done
    for k in $(echo "$move_up_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "if -F '#{pane_at_top}'    '' 'select-pane -U'"; done
    for k in $(echo "$move_right_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "if -F '#{pane_at_right}'  '' 'select-pane -R'"; done
    # tmux bind-key -T copy-mode-vi "$move_left_key"  if -F '#{pane_at_left}'   '' 'select-pane -L'
    # tmux bind-key -T copy-mode-vi "$move_down_key"  if -F '#{pane_at_bottom}' '' 'select-pane -D'
    # tmux bind-key -T copy-mode-vi "$move_up_key"    if -F '#{pane_at_top}'    '' 'select-pane -U'
    # tmux bind-key -T copy-mode-vi "$move_right_key" if -F '#{pane_at_right}'  '' 'select-pane -R'
  fi
}

# Setup all the key-mappings for resizing.
setup_resize() {
  for k in $(echo "$resize_left_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "resize-pane -L $resize_step_size"; done
  for k in $(echo "$resize_down_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "resize-pane -D $resize_step_size"; done
  for k in $(echo "$resize_up_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "resize-pane -U $resize_step_size"; done
  for k in $(echo "$resize_right_key"); do tmux bind-key -n "$k" if -F '#{@pane-is-vim}' "send-keys $k" "resize-pane -R $resize_step_size"; done
}

setup_navigation
setup_resize
