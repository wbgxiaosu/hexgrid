///|
/// Whether the hexagons of a layout have a corner (pointy) or a flat
/// edge on top.
#derive(Eq, Debug)
pub enum Orientation {
  /// Pointy-top hexagons (corner up).
  Pointy
  /// Flat-top hexagons (edge up).
  Flat
}

///|
/// A hexagonal layout: how cells map to the 2D plane. `size` is the
/// distance from the centre to a corner. Pixel conversions follow the
/// matrix formulation of Red Blob Games ("Hexagonal Grids: Layout").
#derive(Eq, Debug)
pub struct Layout {
  orientation : Orientation
  /// Centre-to-corner distance; both components are usually equal.
  size : (Double, Double)
  /// Pixel position of the origin cell.
  origin : (Double, Double)
}

///|
pub extend Orientation with Eq::{equal, not_equal}

///|
pub extend Layout with Eq::{equal, not_equal}

///|
pub extend Orientation with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Layout with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Both orientations, for exhaustive testing.
pub let orientations : Array[Orientation] = [Pointy, Flat]

///|
/// Layout for pointy-top hexagons with unit size at the origin.
pub let pointy_layout : Layout = {
  orientation: Pointy,
  size: (1.0, 1.0),
  origin: (0.0, 0.0),
}

///|
/// Layout for flat-top hexagons with unit size at the origin.
pub let flat_layout : Layout = {
  orientation: Flat,
  size: (1.0, 1.0),
  origin: (0.0, 0.0),
}

///|
/// Converts axial coordinates to pixel coordinates under `layout`.
pub fn Layout::axial_to_pixel(self : Layout, hex : Hex) -> (Double, Double) {
  let (sx, sy) = self.size
  let (ox, oy) = self.origin
  match self.orientation {
    Pointy => {
      let x = sx *
        (
          1.7320508075688772 * hex.q.to_double() +
          0.8660254037844386 * hex.r.to_double()
        )
      let y = sy * (1.5 * hex.r.to_double())
      (x + ox, y + oy)
    }
    Flat => {
      let x = sx * (1.5 * hex.q.to_double())
      let y = sy *
        (
          0.8660254037844386 * hex.q.to_double() +
          1.7320508075688772 * hex.r.to_double()
        )
      (x + ox, y + oy)
    }
  }
}

///|
/// Converts pixel coordinates back to *fractional* axial coordinates;
/// round the result with `Hex::from_pixel_round` to recover a cell.
pub fn Layout::pixel_to_axial(
  self : Layout,
  x : Double,
  y : Double,
) -> (Double, Double) {
  let (sx, sy) = self.size
  let (ox, oy) = self.origin
  let px = (x - ox) / sx
  let py = (y - oy) / sy
  match self.orientation {
    Pointy => {
      let q = 0.5773502691896257 * px - 0.3333333333333333 * py
      let r = 0.6666666666666666 * py
      (q, r)
    }
    Flat => {
      let q = 0.6666666666666666 * px
      let r = -0.3333333333333333 * px + 0.5773502691896257 * py
      (q, r)
    }
  }
}

///|
/// The centre-to-corner size that makes hexagons `width` x `height`
/// pixels (the two numbers of the pair are the bounding box).
pub fn Layout::from_bounds(
  orientation : Orientation,
  width : Double,
  height : Double,
) -> Layout {
  let size = match orientation {
    Pointy => (width / 1.7320508075688772, height / 1.5)
    Flat => (width / 1.5, height / 1.7320508075688772)
  }
  { orientation, size, origin: (0.0, 0.0), }
}
