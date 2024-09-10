//Created by: Zeeshan Ahmad

#include "ChemPotEqual.h"

registerMooseObject("edl_solidApp", ChemPotEqual);

InputParameters
ChemPotEqual::validParams()
{
    InputParameters params = ADKernel::validParams();
    params.addClassDescription("Kernel to enforce pointwise equilibrium of (electro)chemical potentials mua + mub = 0.");
    params.addRequiredParam<MaterialPropertyName>("mua", "The name of the first chemical potential");
    params.addRequiredParam<MaterialPropertyName>("mub", "The name of the second chemical potential");
//    params.addRequiredCoupledVar("lambda", "Lagrange multiplier");
//    params.addRequiredCoupledVar("conc", "concentration");
    params.addCoupledVar("args", "Vector of nonlinear variable arguments this object depends on");
    return params;
}

ChemPotEqual::ChemPotEqual(const InputParameters & parameters)
    : ADKernel(parameters),
//        _eta_name(_var.name()),
        _mua(getADMaterialProperty<Real>("mua")),
        _mub(getADMaterialProperty<Real>("mub"))
//         _dh(getMaterialPropertyDerivative<Real>("h_name", _eta_name)),
//         _d2h(getMaterialPropertyDerivative<Real>("h_name", _eta_name, _eta_name)),
//         _d2ha(isCoupled("args") ? coupledComponents("args") : coupledComponents("coupled_variables")),
//         _d2ha_map(isCoupled("args") ? getParameterJvarMap("args")
//                                                                 : getParameterJvarMap("coupled_variables")),
//         _lambda(coupledValue("lambda")),
//         _lambda_var(coupled("lambda"))
{
//     for (std::size_t i = 0; i < _d2ha.size(); ++i)
//     {
//         if (isCoupled("args"))
//             _d2ha[i] = &getMaterialPropertyDerivative<Real>("h_name", _eta_name, coupledName("args", i));
//         else
//             _d2ha[i] = &getMaterialPropertyDerivative<Real>(
//                     "h_name", _eta_name, coupledName("coupled_variables", i));
//     }
}

ADReal
ChemPotEqual::computeQpResidual()
{

    return  (_mua[_qp] + _mub[_qp]) * _test[_i][_qp];
}

// Real
// ChemPotEqual::computeQpJacobian()
// {
//     return _lambda[_qp] * _d2h[_qp] * _phi[_j][_qp] * _test[_i][_qp];
// }

// Real
// ChemPotEqual::computeQpOffDiagJacobian(unsigned int jvar)
// {
//     if (jvar == _lambda_var)
//         return _phi[_j][_qp] * _dh[_qp] * _test[_i][_qp];

//     auto k = mapJvarToCvar(jvar, _d2ha_map);
//     if (k >= 0)
//         return _lambda[_qp] * (*_d2ha[k])[_qp] * _phi[_j][_qp] * _test[_i][_qp];

//     return 0.0;
// }
