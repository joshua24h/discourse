# frozen_string_literal: true

#mixin for all guardian methods dealing with group permissions
module GroupGuardian

  # Creating Method
  def can_create_group?
    is_admin? ||
    (
      SiteSetting.moderators_manage_categories_and_groups &&
      is_moderator?
    )
  end

  # Edit authority for groups means membership changes only.
  # Automatic groups are not represented in the GROUP_USERS
  # table and thus do not allow membership changes.
  def can_edit_group?(group)
    !group.automatic && can_log_group_changes?(group)
  end

  def can_log_group_changes?(group)
    can_admin_group?(group) || group.users.where('group_users.owner').include?(user)
  end

  def can_admin_group?(group)
    is_admin? ||
    (
      SiteSetting.moderators_manage_categories_and_groups &&
      is_moderator? &&
      can_see?(group) &&
      group.id != Group::AUTO_GROUPS[:admins]
    )
  end

  def can_see_group_messages?(group)
    SiteSetting.enable_personal_messages? && (
      is_admin? || group.users.include?(user)
    )
  end
end
