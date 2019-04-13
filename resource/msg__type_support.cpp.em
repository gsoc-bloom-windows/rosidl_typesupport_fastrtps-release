@# Included from rosidl_typesupport_fastrtps_cpp/resource/idl__type_support.cpp.em
@{
from rosidl_parser.definition import Array
from rosidl_parser.definition import BasicType
from rosidl_parser.definition import BoundedSequence
from rosidl_parser.definition import NamespacedType
from rosidl_parser.definition import NestedType
from rosidl_parser.definition import Sequence
from rosidl_parser.definition import String

header_files = [
    'limits',
    'stdexcept',
    'string',
    'rosidl_typesupport_cpp/message_type_support.hpp',
    'rosidl_typesupport_fastrtps_cpp/identifier.hpp',
    'rosidl_typesupport_fastrtps_cpp/message_type_support.h',
    'rosidl_typesupport_fastrtps_cpp/message_type_support_decl.hpp',
    'fastcdr/Cdr.h',
]
}@
@[for header_file in header_files]@
@[    if header_file in include_directives]@
// already included above
// @
@[    else]@
@{include_directives.add(header_file)}@
@[    end if]@
@[    if '/' not in header_file]@
#include <@(header_file)>
@[    else]@
#include "@(header_file)"
@[    end if]@
@[end for]@


// forward declaration of message dependencies and their conversion functions
@[for member in message.structure.members]@
@{
type_ = member.type
if isinstance(type_, NestedType):
    type_ = type_.basetype
}@
@[  if isinstance(type_, NamespacedType)]@
@[    for ns in type_.namespaces]@
namespace @(ns)
{
@[    end for]@
namespace typesupport_fastrtps_cpp
{
bool cdr_serialize(
  const @('::'.join(type_.namespaces + [type_.name])) &,
  eprosima::fastcdr::Cdr &);
bool cdr_deserialize(
  eprosima::fastcdr::Cdr &,
  @('::'.join(type_.namespaces + [type_.name])) &);
size_t get_serialized_size(
  const @('::'.join(type_.namespaces + [type_.name])) &,
  size_t current_alignment);
size_t
max_serialized_size_@(type_.name)(
  bool & full_bounded,
  size_t current_alignment);
}  // namespace typesupport_fastrtps_cpp
@[    for ns in reversed(type_.namespaces)]@
}  // namespace @(ns)
@[    end for]@

@[  end if]@
@[end for]@
@
@[  for ns in message.structure.type.namespaces]@

namespace @(ns)
{
@[  end for]@

namespace typesupport_fastrtps_cpp
{

bool
ROSIDL_TYPESUPPORT_FASTRTPS_CPP_PUBLIC_@(package_name)
cdr_serialize(
  const @('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])) & ros_message,
  eprosima::fastcdr::Cdr & cdr)
{
@[for member in message.structure.members]@
  // Member: @(member.name)
@[  if isinstance(member.type, NestedType)]@
  {
@[    if isinstance(member.type, Array)]@
@[      if not isinstance(member.type.basetype, NamespacedType)]@
    cdr << ros_message.@(member.name);
@[      else]@
    for (size_t i = 0; i < @(member.type.size); i++) {
      @('::'.join(member.type.basetype.namespaces))::typesupport_fastrtps_cpp::cdr_serialize(
        ros_message.@(member.name)[i],
        cdr);
    }
@[      end if]@
@[    else]@
@[      if isinstance(member.type, BoundedSequence) or isinstance(member.type.basetype, NamespacedType)]@
    size_t size = ros_message.@(member.name).size();
@[        if isinstance(member.type, BoundedSequence)]@
    if (size > @(member.type.upper_bound)) {
      throw std::runtime_error("array size exceeds upper bound");
    }
@[        end if]@
@[      end if]@
@[      if not isinstance(member.type.basetype, NamespacedType) and not isinstance(member.type, BoundedSequence)]@
    cdr << ros_message.@(member.name);
@[      else]@
    cdr << static_cast<uint32_t>(size);
    for (size_t i = 0; i < size; i++) {
@[        if isinstance(member.type.basetype, BasicType) and member.type.basetype.type == 'boolean']@
      cdr << (ros_message.@(member.name)[i] ? true : false);
@[        elif not isinstance(member.type.basetype, NamespacedType)]@
      cdr << ros_message.@(member.name)[i];
@[        else]@
      @('::'.join(member.type.basetype.namespaces))::typesupport_fastrtps_cpp::cdr_serialize(
        ros_message.@(member.name)[i],
        cdr);
@[        end if]@
    }
@[      end if]@
@[    end if]@
  }
@[  elif isinstance(member.type, BasicType) and member.type.type == 'boolean']@
  cdr << (ros_message.@(member.name) ? true : false);
@[  elif not isinstance(member.type, NamespacedType)]@
  cdr << ros_message.@(member.name);
@[  else]@
  @('::'.join(member.type.namespaces))::typesupport_fastrtps_cpp::cdr_serialize(
    ros_message.@(member.name),
    cdr);
@[  end if]@
@[end for]@
  return true;
}

bool
ROSIDL_TYPESUPPORT_FASTRTPS_CPP_PUBLIC_@(package_name)
cdr_deserialize(
  eprosima::fastcdr::Cdr & cdr,
  @('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])) & ros_message)
{
@[for member in message.structure.members]@
  // Member: @(member.name)
@[  if isinstance(member.type, NestedType)]@
  {
@[    if isinstance(member.type, Array)]@
@[      if not isinstance(member.type.basetype, NamespacedType)]@
    cdr >> ros_message.@(member.name);
@[      else]@
    for (size_t i = 0; i < @(member.type.size); i++) {
      @('::'.join(member.type.basetype.namespaces))::typesupport_fastrtps_cpp::cdr_deserialize(
        cdr,
        ros_message.@(member.name)[i]);
    }
@[      end if]@
@[    else]@
@[      if not isinstance(member.type.basetype, NamespacedType) and not isinstance(member.type, BoundedSequence)]@
    cdr >> ros_message.@(member.name);
@[      else]@
    uint32_t cdrSize;
    cdr >> cdrSize;
    size_t size = static_cast<size_t>(cdrSize);
    ros_message.@(member.name).resize(size);
    for (size_t i = 0; i < size; i++) {
@[        if isinstance(member.type.basetype, BasicType) and member.type.basetype.type == 'boolean']@
      uint8_t tmp;
      cdr >> tmp;
      ros_message.@(member.name)[i] = tmp ? true : false;
@[        elif not isinstance(member.type.basetype, NamespacedType)]@
      cdr >> ros_message.@(member.name)[i];
@[        else]@
      @('::'.join(member.type.basetype.namespaces))::typesupport_fastrtps_cpp::cdr_deserialize(
        cdr, ros_message.@(member.name)[i]);
@[        end if]@
    }
@[      end if]@
@[    end if]@
  }
@[  elif isinstance(member.type, BasicType) and member.type.type == 'boolean']@
  {
    uint8_t tmp;
    cdr >> tmp;
    ros_message.@(member.name) = tmp ? true : false;
  }
@[  elif not isinstance(member.type, NamespacedType)]@
  cdr >> ros_message.@(member.name);
@[  else]@
  @('::'.join(member.type.namespaces))::typesupport_fastrtps_cpp::cdr_deserialize(
    cdr, ros_message.@(member.name));
@[  end if]@

@[end for]@
  return true;
}

size_t
ROSIDL_TYPESUPPORT_FASTRTPS_CPP_PUBLIC_@(package_name)
get_serialized_size(
  const @('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])) & ros_message,
  size_t current_alignment)
{
  size_t initial_alignment = current_alignment;

  const size_t padding = 4;
  (void)padding;

@[for member in message.structure.members]@
  // Member: @(member.name)
@[  if isinstance(member.type, NestedType)]@
  {
@[    if isinstance(member.type, Array)]@
    size_t array_size = @(member.type.size);
@[    else]@
    size_t array_size = ros_message.@(member.name).size();
@[      if isinstance(member.type, BoundedSequence)]@
    if (array_size > @(member.type.upper_bound)) {
      throw std::runtime_error("array size exceeds upper bound");
    }
@[      end if]@

    current_alignment += padding +
      eprosima::fastcdr::Cdr::alignment(current_alignment, padding);
@[    end if]@
@[    if isinstance(member.type.basetype, String)]@
    for (size_t index = 0; index < array_size; ++index) {
      current_alignment += padding +
        eprosima::fastcdr::Cdr::alignment(current_alignment, padding) +
        ros_message.@(member.name)[index].size() + 1;
    }
@[    elif isinstance(member.type.basetype, BasicType)]@
    size_t item_size = sizeof(ros_message.@(member.name)[0]);
    current_alignment += array_size * item_size +
      eprosima::fastcdr::Cdr::alignment(current_alignment, item_size);
@[    else]
    for (size_t index = 0; index < array_size; ++index) {
      current_alignment +=
        @('::'.join(member.type.basetype.namespaces))::typesupport_fastrtps_cpp::get_serialized_size(
        ros_message.@(member.name)[index], current_alignment);
    }
@[    end if]@
  }
@[  else]@
@[    if isinstance(member.type, String)]@
  current_alignment += padding +
    eprosima::fastcdr::Cdr::alignment(current_alignment, padding) +
    ros_message.@(member.name).size() + 1;
@[    elif isinstance(member.type, BasicType)]@
  {
    size_t item_size = sizeof(ros_message.@(member.name));
    current_alignment += item_size +
      eprosima::fastcdr::Cdr::alignment(current_alignment, item_size);
  }
@[    else]
  current_alignment +=
    @('::'.join(member.type.namespaces))::typesupport_fastrtps_cpp::get_serialized_size(
    ros_message.@(member.name), current_alignment);
@[    end if]@
@[  end if]@
@[end for]@

  return current_alignment - initial_alignment;
}

size_t
ROSIDL_TYPESUPPORT_FASTRTPS_CPP_PUBLIC_@(package_name)
max_serialized_size_@(message.structure.type.name)(
  bool & full_bounded,
  size_t current_alignment)
{
  size_t initial_alignment = current_alignment;

  const size_t padding = 4;
  (void)padding;
  (void)full_bounded;

@[for member in message.structure.members]@
  // Member: @(member.name)
  {
@[  if isinstance(member.type, NestedType)]@
@[    if isinstance(member.type, Array)]@
    size_t array_size = @(member.type.size);
@[    elif isinstance(member.type, BoundedSequence)]@
    size_t array_size = @(member.type.upper_bound);
@[    else]@
    size_t array_size = 0;
@[    end if]@
@[    if isinstance(member.type, Sequence)]@
    full_bounded = false;
    current_alignment += padding +
      eprosima::fastcdr::Cdr::alignment(current_alignment, padding);
@[    end if]@
@[  else]@
    size_t array_size = 1;
@[  end if]@

@{
type_ = member.type
if isinstance(type_, NestedType):
    type_ = type_.basetype
}@
@[  if isinstance(type_, String)]@
    full_bounded = false;
    for (size_t index = 0; index < array_size; ++index) {
      current_alignment += padding +
@[    if type_.maximum_size]@
        eprosima::fastcdr::Cdr::alignment(current_alignment, padding) +
        @(type_.maximum_size) + 1;
@[    else]@
        eprosima::fastcdr::Cdr::alignment(current_alignment, padding) + 1;
@[    end if]@
    }
@[  elif isinstance(type_, BasicType)]@
@[    if type_.type in ('boolean', 'octet', 'char', 'uint8', 'int8')]@
    current_alignment += array_size * sizeof(uint8_t);
@[    elif type_.type in ('int16', 'uint16')]@
    current_alignment += array_size * sizeof(uint16_t) +
      eprosima::fastcdr::Cdr::alignment(current_alignment, sizeof(uint16_t));
@[    elif type_.type in ('int32', 'uint32', 'float')]@
    current_alignment += array_size * sizeof(uint32_t) +
      eprosima::fastcdr::Cdr::alignment(current_alignment, sizeof(uint32_t));
@[    elif type_.type in ('int64', 'uint64', 'double')]@
    current_alignment += array_size * sizeof(uint64_t) +
      eprosima::fastcdr::Cdr::alignment(current_alignment, sizeof(uint64_t));
@[    end if]@
@[  else]
    for (size_t index = 0; index < array_size; ++index) {
      current_alignment +=
        @('::'.join(type_.namespaces))::typesupport_fastrtps_cpp::max_serialized_size_@(type_.name)(
        full_bounded, current_alignment);
    }
@[  end if]@
  }
@[end for]@

  return current_alignment - initial_alignment;
}

static bool _@(message.structure.type.name)__cdr_serialize(
  const void * untyped_ros_message,
  eprosima::fastcdr::Cdr & cdr)
{
  auto typed_message =
    static_cast<const @('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])) *>(
    untyped_ros_message);
  return cdr_serialize(*typed_message, cdr);
}

static bool _@(message.structure.type.name)__cdr_deserialize(
  eprosima::fastcdr::Cdr & cdr,
  void * untyped_ros_message)
{
  auto typed_message =
    static_cast<@('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])) *>(
    untyped_ros_message);
  return cdr_deserialize(cdr, *typed_message);
}

static uint32_t _@(message.structure.type.name)__get_serialized_size(
  const void * untyped_ros_message)
{
  auto typed_message =
    static_cast<const @('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])) *>(
    untyped_ros_message);
  return static_cast<uint32_t>(get_serialized_size(*typed_message, 0));
}

static size_t _@(message.structure.type.name)__max_serialized_size(bool & full_bounded)
{
  return max_serialized_size_@(message.structure.type.name)(full_bounded, 0);
}

static message_type_support_callbacks_t _@(message.structure.type.name)__callbacks = {
  "@(package_name)",
  "@(message.structure.type.name)",
  _@(message.structure.type.name)__cdr_serialize,
  _@(message.structure.type.name)__cdr_deserialize,
  _@(message.structure.type.name)__get_serialized_size,
  _@(message.structure.type.name)__max_serialized_size
};

static rosidl_message_type_support_t _@(message.structure.type.name)__handle = {
  rosidl_typesupport_fastrtps_cpp::typesupport_identifier,
  &_@(message.structure.type.name)__callbacks,
  get_message_typesupport_handle_function,
};

}  // namespace typesupport_fastrtps_cpp
@[  for ns in reversed(message.structure.type.namespaces)]@

}  // namespace @(ns)
@[  end for]@

namespace rosidl_typesupport_fastrtps_cpp
{

template<>
ROSIDL_TYPESUPPORT_FASTRTPS_CPP_EXPORT_@(package_name)
const rosidl_message_type_support_t *
get_message_type_support_handle<@('::'.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name]))>()
{
  return &@('::'.join([package_name] + list(interface_path.parents[0].parts)))::typesupport_fastrtps_cpp::_@(message.structure.type.name)__handle;
}

}  // namespace rosidl_typesupport_fastrtps_cpp

#ifdef __cplusplus
extern "C"
{
#endif

const rosidl_message_type_support_t *
ROSIDL_TYPESUPPORT_INTERFACE__MESSAGE_SYMBOL_NAME(rosidl_typesupport_fastrtps_cpp, @(', '.join([package_name] + list(interface_path.parents[0].parts) + [message.structure.type.name])))() {
  return &@('::'.join([package_name] + list(interface_path.parents[0].parts)))::typesupport_fastrtps_cpp::_@(message.structure.type.name)__handle;
}

#ifdef __cplusplus
}
#endif