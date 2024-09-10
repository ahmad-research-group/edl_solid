//Created by: Zeeshan Ahmad                                                                                                           

#pragma once

#include "ADKernel.h"
#include "DerivativeMaterialPropertyNameInterface.h"


class ChemPotValue : public ADKernel, public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  ChemPotValue(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual();

  /// Mobility                                                                                                                                                
  const ADMaterialProperty<Real> & _mutarget, & _mu;

//   /// Interfacial parameter                                                                                                                                   
//   const ADMaterialProperty<Real> & _kappa;
};