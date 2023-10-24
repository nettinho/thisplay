defmodule ImageHelper do
  def crop_image(input_path, output_path, width, height, x_offset, y_offset) do
    input_path
    |> Mogrify.open()
    |> Mogrify.crop(width, height, x_offset, y_offset)
    |> Mogrify.save(path: output_path)
  end

  def get_dimensions(image_path) do
    image = Mogrify.open(image_path)
    {image.width(), image.height()}
  end
end
